package.path = "../../db/?.lua;" .. package.path
package.cpath = "./../lua-cjson/?.so;"..package.cpath
local skynet = require "skynet"
local mc = require "multicast"
local mysql = require "mysql"
local redis = require "redis"
local util = require "util"
local queue = require "lqueue"
local log = require "log"
local name = ...

local db
local cache
local readq = queue.new(16)
local write

local function dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end

local function connect_mysql(conf)
	local function on_connect( db )
		db:query( "set charset utf8" )
	end
	local c = {
		host = conf.host or "192.168.1.116",
		port = conf.port or 3306,
		database = conf.database or "project",
		user = conf.user or "root",
		password = conf.password or "yulei",
		max_packet_size = 1024 * 1024,
		on_connect = on_connect,
	}
	return mysql.connect(c)
end

local function disconnect_mysql( ... )
	-- body
	if db then
		db:disconnect()
	end
end

local function watching(conf)
	local w = redis.watch( conf )
	w:subscribe "foo"
	w:psubscribe "hello.*"
	
	while true do
		print( "watch" , w:message() )
	end
end	

local function connect_redis(conf)
	--skynet.fork( watching, conf )
	local c = {
		host = conf.host or "192.168.1.116",
		port = conf.port or 6379,
		db = 0
	}
	return redis.connect(c)	
end	

local function disconnect_redis( ... )
	-- body
	if cache then
		cache:disconnect()
	end
end

local QUERY = {}

function QUERY.select(table_name, sql)
	-- body
	if name == "master" then
		local db = queue.dequeue(readq)
		local res = skynet.call(db, "lua", "query", "select", table_name, sql)
		queue.enqueue(readq, db)
		return res
	elseif name == "slave" then
		local res = db:query(sql)
		dump(res)	
		return res
	end
end

function QUERY.update(table_name, sql)
	-- body
	if name == "master" then
		skynet.send(write, "lua", "query", "update", table_name, sql)
	elseif name == "slave" then
		local res = db:query(sql)
		dump(res)
	end
end

function QUERY.insert(table_name, sql, ... )
	-- body
	if name == "master" then
		skynet.send(write, "lua", "query", "update", table_name, sql)
	elseif name == "slave" then
		local res = db:query(sql)
		dump(res)
	end
end

function QUERY.get(k, sub)
	-- body
	if name == "master" then
		local db = queue.dequeue(readq)
		local res = skynet.call(db, "lua", "query", "get", k, sub)
		queue.enqueue(readq, db)
		return res
	else
		return cache:get(k)
	end
end

function QUERY.set(k, v)
	-- body
	if name == "master" then
		skynet.send(write, "lua", "query", "set", k, v)
	elseif name == "slave" then
		cache:set(k, v)
	end
end

function QUERY.hget(k, kk, ... )
	-- body
	if name == "master" then
		local db = queue.dequeue(readq)
		local res = skynet.call(db, "lua", "query", "hget", k, kk)
		queue.enqueue(readq, db)
		return res
	elseif name == "slave" then
		return cache:hvals(k)
	end
end

function QUERY.hset(k, kk, vv, ... )
	-- body
	if name == "master" then
		skynet.send(write, "lua", "query", "hset", k, kk, vv)
	elseif name == "slave" then
		cache:hset(k, kk, vv)
	end
end

local CMD = {}
			
function CMD.start(conf)
	-- body
	if name == "master" then
		write = skynet.newservice("db", "slave")
		skynet.call(write, "lua", "start", conf)
		for i=1,10 do
			local db = skynet.newservice("db", "slave")
			skynet.call(db, "lua", "start", conf)
			queue.enqueue(readq, db)
		end
	elseif name == "slave" then
		local db_conf = {
			host = conf.db_host,
			port = conf.db_port or 3306,
			database = conf.db_database or "project",
			user = conf.db_user or "root",
			password = conf.db_password or "yulei",
		}
		db = connect_mysql(db_conf)
		local cache_conf = {
			host = conf.cache_host,
			port = conf.cache_port or 6379,
			db = 0
		}
		cache = connect_redis(cache_conf)
	end
	return true
end

function CMD.close()
	-- body
	if name == "master" then
		skynet.call(write, "lua", "close")
		local db = queue.dequeue(readq)
		while db do
			skynet.call(db, "lua", "close")
			db = queue.dequeue(readq)
		end
	elseif name == "slave" then
	end
end

function CMD.kill( ... )
	-- body
	if name == "master" then
		skynet.call(write, "lua", "kill")
		local db = queue.dequeue(readq)
		while db do
			skynet.call(db, "lua", "kill")
			db = queue.dequeue(readq)
		end
		skynet.exit()
		return true
	elseif name == "slave" then
		skynet.exit()
		return true
	end
end

skynet.start(function ()
	skynet.dispatch( "lua" , function( _, _, cmd, subcmd, ... )
		if cmd == "query" then
			local f = QUERY[subcmd]
			local r = f( ... )
			if f ~= nil then
				skynet.retpack(r)
			end
		else
			local f = assert(CMD[cmd], cmd)
			local r = f(subcmd, ...)
			if r ~= nil then
				skynet.retpack(r)
			end
		end
	end)
	if name == "master" then
		skynet.register ".DB"
	end
end)
