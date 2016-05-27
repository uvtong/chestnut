package.path = "./../db/?.lua;./../lualib/?.lua;./../cat/?.lua;" .. package.path
package.cpath = "./../lua-cjson/?.so;"..package.cpath
local skynet = require "skynet"
local mc = require "multicast"
local mysql = require "mysql"
local redis = require "redis"
local util = require "util"
local Queue = require "queue"
local name = ...
local frienddb = require "frienddb"
local queue = require "skynet.queue"

local cs1 = queue()

local env = {}
env.DB_PRIORITY_1 = 1
env.DB_PRIORITY_2 = 2
env.DB_PRIORITY_3 = 3
env.DB_DELTA = 6000
env.c_priority = env.DB_PRIORITY_1
env.db = false
env.cache = false
env.priority_queue = {}

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

local function train(ctx, priority)
	-- body
	while true do
		if ctx.c_priority ~= priority then
			skynet.wait()
		end
		local r = Queue.dequeue(ctx.priority_queue[ctx.c_priority].Q)
		if r then
			local db = ctx.db
			if db then
				print("SQL statement:", r.sql)
				local res = db:query(r.sql)
				print(string.format("query %s result=", r.table_name), dump(res))
			else
				error "db is lost."
			end
		else
			if ctx.c_priority < ctx.DB_PRIORITY_3 then
				ctx.c_priority = ctx.c_priority + 1
				local co = ctx.priority_queue[ctx.c_priority].co
				skynet.wakeup(co)
				print(string.format("priority Queue %d end", priority))
			else
				print(string.format("priority Queue %d end", priority))
				skynet.wait()
			end
		end
	end
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
		
local QUERY = {}

function QUERY:query(sql)
	-- body
	-- local res = cs1(self.db.query, db, sql)
	-- return res
	local db = self.db
	local res = db:query(sql)
	dump(res)
	return res
end

function QUERY:read(table_name, sql)
	-- body
	-- local res = cs1(self.db.query, db, sql)
	-- return res
	local db = self.db
	local res = db:query(sql)
	dump(res)
	return res
end

function QUERY:write(table_name, sql, priority)
	-- body
	local db = self.db
	local res = db:query(sql)
	dump(res)
	-- local res = cs1(self.db.query, db, sql)
	-- return res
	-- print("QUERY:write", sql)
	-- assert(table_name and sql and priority)
	-- assert(priority <= self.DB_PRIORITY_3 and priority >= self.DB_PRIORITY_1)
	-- Queue.enqueue(self.priority_queue[priority].Q, { table_name=table_name, sql=sql})
	-- if priority <= self.c_priority then
	-- 	self.c_priority = priority
	-- 	-- skynet.yield() -- 
	-- 	local co = self.priority_queue[self.c_priority].co
	-- 	skynet.wakeup(co)
	-- end
end

function QUERY:set(k, v)
	-- body
	assert(type(k) == "string")
	assert(type(k) == "string")
	self.cache:set(k, v)
end

function QUERY:hset(k, kk, vv, ... )
	-- body
	self.cache:hset(k, kk, vv)
end

function QUERY:get(k, sub)
	-- body
	assert(type(k) == "string")
	assert(type(sub) == "string")
	local v = self.cache:get(k)
	if sub ~= nil then
		v = json.decode(v)
		return v[sub]
	else
		return v
	end
end

-- function QUERY:query( sql )
-- 	-- body
-- 	return self.db:query(sql)
-- end

-- function QUERY:select( table_name, condition, columns)
-- 	-- body
-- 	local sql = util.select(table_name, condition, columns)
-- 	local r = self.db:query(sql)
-- 	return r
-- end

-- function QUERY:update( table_name, condition, columns, priority)
-- 	-- body
-- 	assert(priority and priority >= self.DB_PRIORITY_1 and priority <= self.DB_PRIORITY_3, string.format("when query %s you must provide priority", table_name))
-- 	local sql = util.update(table_name, condition, columns)
-- 	assert(table_name and sql and priority)
-- 	assert(priority <= self.DB_PRIORITY_3 and priority >= self.DB_PRIORITY_1)
-- 	Queue.enqueue(self.priority_queue[priority].Q, { table_name=table_name, sql=sql})
-- 	if priority <= self.c_priority then
-- 		self.c_priority = priority
-- 		-- skynet.yield() -- 
-- 		local co = self.priority_queue[self.c_priority].co
-- 		skynet.wakeup(co)
-- 	end
-- end

-- function QUERY:insert( table_name, columns, priority)
-- 	-- body
-- 	assert(priority and priority >= self.DB_PRIORITY_1 and priority <= self.DB_PRIORITY_3, string.format("when query %s you must provide priority", table_name))
-- 	local sql = util.insert(table_name, columns)
-- 	assert(table_name and sql and priority)
-- 	assert(priority <= self.DB_PRIORITY_3 and priority >= self.DB_PRIORITY_1)
-- 	Queue.enqueue(self.priority_queue[priority].Q, { table_name=table_name, sql=sql})
-- 	if priority <= self.c_priority then
-- 		self.c_priority = priority
-- 		-- skynet.yield() -- 
-- 		local co = self.priority_queue[self.c_priority].co
-- 		skynet.wakeup(co)
-- 	end
-- end

-- function QUERY:insert_wait( table_name, columns, priority)
-- 	-- body
-- 	assert(priority and priority >= self.DB_PRIORITY_1 and priority <= self.DB_PRIORITY_3, string.format("when query %s you must provide priority", table_name))
-- 	local sql = util.insert(table_name, columns)
-- 	local res = self.db:query(sql)
-- 	print(dump(res))
-- 	return res
-- end

-- function QUERY:insert_all( table_name , tcolumns, priority)
-- 	assert(priority and priority >= self.DB_PRIORITY_1 and priority <= self.DB_PRIORITY_3, string.format("when query %s you must provide priority", table_name))
-- 	local sql = util.insert_all( table_name , tcolumns )
-- 	assert(table_name and sql and priority)
-- 	assert(priority <= self.DB_PRIORITY_3 and priority >= self.DB_PRIORITY_1)
-- 	Queue.enqueue(self.priority_queue[priority].Q, { table_name=table_name, sql=sql})
-- 	if priority <= self.c_priority then
-- 		self.c_priority = priority
-- 		-- skynet.yield() -- 
-- 		local co = self.priority_queue[self.c_priority].co
-- 		skynet.wakeup(co)
-- 	end
-- end

-- function QUERY:update_all(table_name, condition, columns, data, priority)
-- 	-- body
-- 	assert(priority and priority >= self.DB_PRIORITY_1 and priority <= self.DB_PRIORITY_3, string.format("when query %s you must provide priority", table_name))
-- 	local sql = util.update_all(table_name, condition, columns, data)
-- 	assert(table_name and sql and priority)
-- 	assert(priority <= self.DB_PRIORITY_3 and priority >= self.DB_PRIORITY_1)
-- 	Queue.enqueue(self.priority_queue[priority].Q, { table_name=table_name, sql=sql})
-- 	if priority <= self.c_priority then
-- 		self.c_priority = priority
-- 		-- skynet.yield() -- 
-- 		local co = self.priority_queue[self.c_priority].co
-- 		skynet.wakeup(co)
-- 	end
-- end

-- friend	
-- function QUERY:select_user( condition, columns )
-- 	-- body
-- 	-- userid, uaccount, upassword
-- 	local sql = util.select("users", condition, columns)
-- 	local r = self.db:query(sql, condition)
-- 	--cache:get()
-- 	return r[1]
-- end 	

function QUERY:getrandomval( drawtype )
	assert( drawtype )
	local sql3 = string.format( "select step from randomval" )
	local r = self.db:query( sql3 )
	if #r == 0 then
		print( "r == 3 " )
	end
		
	local step = r[drawtype].step

	local sql1 = string.format( "update randomval set val = val + %s where id = %s" , step , drawtype )
	
	local sql2 = string.format( "select val from randomval where id = %s" , drawtype )
	print( sql1 )
	print( sql2 )
	
	self.db:query( sql1 )
	local r = self.db:query( sql2 )
	print( "update randomval is over" )
	print( r[1].val , drawtype , r  )
	return r[1].val % 10000
end	

local CMD = {}
		
function CMD.disconnect_redis(ctx, ... )
	ctx.cache:disconnect()
end	
	
function CMD.disconnect_mysql(ctx, ... )
	ctx.db:disconnect()
end
	
function CMD.start(ctx, conf)
	-- body
	local db_conf = {
		host = conf.db_host or "192.168.1.116",
		port = conf.db_port or 3306,
		database = conf.db_database or "project",
		user = conf.db_user or "root",
		password = conf.db_password or "yulei",
	}
	ctx.db = connect_mysql(db_conf)
	local cache_conf = {
		host = conf.cache_host or "192.168.1.116",
		port = conf.cache_port or 6379,
		db = 0
	}
	ctx.cache = connect_redis(cache_conf)
	frienddb.getvalue(ctx.db, ctx.cache)
	local Q1 = Queue.new(128)
	local Q2 = Queue.new(128)
	local Q3 = Queue.new(128)
	
	local co1 = skynet.fork(train, ctx, ctx.DB_PRIORITY_1)
	local co2 = skynet.fork(train, ctx, ctx.DB_PRIORITY_2)
	local co3 = skynet.fork(train, ctx, ctx.DB_PRIORITY_3)

	ctx.priority_queue[ctx.DB_PRIORITY_1] = { Q = Q1, co = co1}
	ctx.priority_queue[ctx.DB_PRIORITY_2] = { Q = Q2, co = co2}
	ctx.priority_queue[ctx.DB_PRIORITY_3] = { Q = Q3, co = co3}
	return true
end

function CMD.test(ctx)
	-- body
	local sql = "select * from u_prop"
	local r = ctx.db:query(sql)
	-- dump(r)kjll;''
	-- ctx.cache:set("abc", "ace")
	print("******************ace")
	return "annalajflajfa"
end

local START_SUBSCRIBE = {}

local function check_q()
	-- body
	if not Queue.is_empty(priority_queue[const.DB_PRIORITY_1].Q) then
		print("suspend1")
		skynet.wakeup(priority_queue[const.DB_PRIORITY_1].co)
		return false
	end
	if not Queue.is_empty(priority_queue[const.DB_PRIORITY_2].Q) then
		print("suspend2")
		skynet.wakeup(priority_queue[const.DB_PRIORITY_2].co)
		return false
	end
	if not Queue.is_empty(priority_queue[const.DB_PRIORITY_3].Q) then
		print("suspend3")
		skynet.wakeup(priority_queue[const.DB_PRIORITY_3].co)
		return false
	end
	return true
end

function START_SUBSCRIBE.finish(ctx, source, ...)
	-- body
	print(string.format("the node  %s will be finished. you should clean something.", name))
	-- while not check_q() do
	-- 	skynet.sleep(100)
	-- end
	skynet.send(source, "lua", "exit")
end

function START_SUBSCRIBE.test(ctx, source, msg)
	-- body
	print(name, msg)
end

local function start_subscribe()
	-- body
	print("start_subscribe", name)
	local c = skynet.call(".start_service", "lua", "register")
	local c2 = mc.new {
		channel = c,
		dispatch = function (channel, source, cmd, ...)
			-- body
			print(name, "test subscribe")
			local f = START_SUBSCRIBE[cmd]
			if f then
				f(env, source, ...)
			end
		end
	}
	c2:subscribe()
end

local function command(subcmd, table_name, ... )
	-- body
	local f = QUERY[subcmd]
	if f then
		return f(env, table_name, ...)
	elseif frienddb[subcmd] then
		f = frienddb[subcmd]
		return f(frienddb, table_name, ...)
	else
		error(string.format("db node for table_name %s cmd %s will not be called.", table_name, subcmd))
	end
end

skynet.start(function ()
	skynet.dispatch( "lua" , function( _, _, cmd, subcmd, ... )
		if cmd == "command" then
			local r = command(subcmd, ...)
			if r then
				skynet.ret(skynet.pack(r))
			end
		else
			local f = assert(CMD[cmd])
			local r = f(env, subcmd, ...)
			if r then
				skynet.ret(skynet.pack(r))
			end
		end
	end)
	start_subscribe()
end)
