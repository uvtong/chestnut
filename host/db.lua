package.path = "./../cat/?.lua;" .. package.path
local skynet = require "skynet"
local mysql = require "mysql"
local redis = require "redis"
local util = require "util"

local db
local cache 

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
		
local QUERY = {}

function QUERY:query( sql )
	-- body
	return db:query(sql)
end

function QUERY:select( table_name, condition, columns)
	-- body
	local sql = util.select(table_name, condition, columns)
	return db:query(sql)
end

function QUERY:update( table_name, condition, columns )
	-- body
	local sql = util.update(table_name, condition, columns)
	db:query(sql)
end

function QUERY:insert( table_name, columns )
	-- body
	local sql = util.insert(table_name, columns)
	db:query(sql)
end
	
local CMD = {}
		
function CMD:disconnect_redis( ... )
	cache:disconnect()
end	
	
function CMD:disconnect_mysql( ... )
	db:disconnect()
end	
	
function CMD:command( subcmd, ... )
	local f = assert(QUERY[subcmd])
	return f(QUERY, ... )
end

local
function connect_mysql( ... )
	local function on_connect( db )
		db:query( "set charset utf8" )
	end
	
	local db = mysql.connect( { 
		-- host = "192.168.1.116",
		host = "192.168.1.106",
		port = 3306,
		database = "project",
		user = "root",
		password = "123456",
		-- password = "yulei",
		max_packet_size = 1024 * 1024,
		on_connect = on_connect,
	} )

	return db
end

local
function watching(conf)
	local w = redis.watch( conf )
	w:subscribe "foo"
	w:psubscribe "hello.*"
	
	while true do
		print( "watch" , w:message() )
	end
end	

local
function connect_redis( conf )
	--skynet.fork( watching, conf )
	local cache = redis.connect( conf )	
	return cache
end	

skynet.start( function () 
	skynet.dispatch( "lua" , function( _, _, cmd, subcmd, ... )
		if cmd == "command" then
			local f = assert( CMD[ cmd ] )
			local result = f(CMD, subcmd, ... )
			if result then
				skynet.ret( skynet.pack( result ) )
			end
		else
			local f = assert( CMD[ cmd ] )
			skynet.ret( skynet.pack( f( subcmd, ... ) ) )
		end
	end)

	db = connect_mysql()
	local conf = {
		host = "192.168.1.116",
		port = 6379,
		db = 0
	}
	-- cache = connect_redis( conf )

	--skynet.call( ".channel" , "lua" , "get_db_cache" , emaildb )
end)
