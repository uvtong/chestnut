package.path = "./../cat/?.lua;./../cat/lualib/?.lua;" .. package.path
local skynet = require "skynet"
local mysql = require "mysql"
local redis = require "redis"
local util = require "util"
local Queue = require "queue"
local const = require "const"

local frienddb = require "frienddb"

local db
local cache 
local priority_queue = {}
local c_priority = const.DB_PRIORITY_1

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

function QUERY:update( table_name, condition, columns, priority)
	-- body
	assert(priority and priority >= const.DB_PRIORITY_1 and priority <= const.DB_PRIORITY_3, string.format("when query %s you must provide priority", table_name))
	local sql = util.update(table_name, condition, columns)
	if priority == const.DB_PRIORITY_1 then
		Queue.enqueue(priority_queue[priority].Q, { table_name=table_name, sql=sql})
	elseif priority == const.DB_PRIORITY_2 then
		Queue.enqueue(priority_queue[priority].Q, { table_name=table_name, sql=sql})
	elseif priority == const.DB_PRIORITY_3 then
		Queue.enqueue(priority_queue[priority].Q, { table_name=table_name, sql=sql})
	else
		assert(false)
	end
	
	if c_priority > priority then
		c_priority = priority
		print(c_priority)
		-- skynet.yield() -- 
		skynet.wakeup(priority_queue[c_priority].co)
	end
	
	-- db:query(sql)
end

function QUERY:insert( table_name, columns, priority)
	-- body
	assert(priority and priority >= const.DB_PRIORITY_1 and priority <= const.DB_PRIORITY_3, string.format("when query %s you must provide priority", table_name))
	local sql = util.insert(table_name, columns)
	if priority == const.DB_PRIORITY_1 then
		Queue.enqueue(priority_queue[priority].Q, { table_name=table_name, sql=sql})
	elseif priority == const.DB_PRIORITY_2 then
		Queue.enqueue(priority_queue[priority].Q, { table_name=table_name, sql=sql})
	elseif priority == const.DB_PRIORITY_3 then
		Queue.enqueue(priority_queue[priority].Q, { table_name=table_name, sql=sql})
	end
	
	if c_priority > priority then
		c_priority = priority
		-- skynet.yield() -- 
		skynet.wakeup(priority_queue[c_priority].co)
	end
	-- Queue.enqueue(Q, sql)
	-- db:query(sql)
end

function QUERY:insert_all( table_name , tcolumns, priority)
	assert(priority and priority >= const.DB_PRIORITY_1 and priority <= const.DB_PRIORITY_3, string.format("when query %s you must provide priority", table_name))
	local sql = util.insert_all( table_name , tcolumns )
	if priority == const.DB_PRIORITY_1 then
		Queue.enqueue(priority_queue[priority].Q, { table_name=table_name, sql=sql})
	elseif priority == const.DB_PRIORITY_2 then
		Queue.enqueue(priority_queue[priority].Q, { table_name=table_name, sql=sql})
	elseif priority == const.DB_PRIORITY_3 then
		Queue.enqueue(priority_queue[priority].Q, { table_name=table_name, sql=sql})
	end
	if c_priority > priority then
		c_priority = priority
		-- skynet.yield() -- 
		skynet.wakeup(priority_queue[c_priority].co)
	end
	-- Queue.enqueue(Q, sql)
	-- db:query(sql)
end

function QUERY:update_all( table_name, condition, columns, data, priority)
	-- body
	assert(priority and priority >= const.DB_PRIORITY_1 and priority <= const.DB_PRIORITY_3, string.format("when query %s you must provide priority", table_name))
	local sql = util.update_all(table_name, condition, columns, data)
	if priority == const.DB_PRIORITY_1 then
		Queue.enqueue(priority_queue[priority].Q, { table_name=table_name, sql=sql})
	elseif priority == const.DB_PRIORITY_2 then
		Queue.enqueue(priority_queue[priority].Q, { table_name=table_name, sql=sql})
	elseif priority == const.DB_PRIORITY_3 then
		Queue.enqueue(priority_queue[priority].Q, { table_name=table_name, sql=sql})
	end
	
	if c_priority > priority then
		c_priority = priority
		-- skynet.yield() -- 
		skynet.wakeup(priority_queue[priority].co)
	end

	-- Queue.enqueue(Q, { table_name=table_name, sql=sql})
end

-- friend	
function QUERY:select_user( condition, columns )
	-- body
	-- userid, uaccount, upassword
	local sql = util.select("users", condition, columns)
	local r = db:query(sql, condition)
	--cache:get()
	return r[1]
end 	

function QUERY:getrandomval( drawtype )
	assert( drawtype )
	local sql3 = string.format( "select step from randomval" )
	local r = db:query( sql3 )
	if #r == 0 then
		print( "r == 3 " )
	end
		
	local step = r[drawtype].step

	local sql1 = string.format( "update randomval set val = val + %s where id = %s" , step , drawtype )
	
	local sql2 = string.format( "select val from randomval where id = %s" , drawtype )
	print( sql1 )
	print( sql2 )
	
	db:query( sql1 )
	local r = db:query( sql2 )
	print( "update randomval is over" )
	print( r[1].val , drawtype , r  )
	return r[1].val % 10000
end	
	
local CMD = {}
		
function CMD:disconnect_redis( ... )
	cache:disconnect()
end	
	
function CMD:disconnect_mysql( ... )
	db:disconnect()
end	
	
function CMD:command( subcmd, ... )
	local f = nil
    if nil ~= QUERY[subcmd] then
    	f = assert(QUERY[ subcmd ])
		return f(QUERY, ... )
	elseif nil ~= frienddb[ subcmd ] then
		f = assert( frienddb[ subcmd ] )
		return f(frienddb, ...)
	else
		print(subcmd)
		assert( f )
    end
end

local
function connect_mysql( ... )
	local function on_connect( db )
		db:query( "set charset utf8" )
	end
	
	local db = mysql.connect( { 
		host = "192.168.1.116",
		port = 3306,
		database = "project",
		user = "root",
		password = "yulei",
		max_packet_size = 1024 * 1024,
		on_connect = on_connect,
	} )

	return db
end

local function query_mysql1()
	-- body
	while true do
		if c_priority ~= const.DB_PRIORITY_1 then
			skynet.wait()
		end
		local r = Queue.dequeue(Q1) 
		if r then
			local res = db:query(r.sql)
			print(string.format("query %s result=", r.table_name), dump(res))
		else
			if c_priority < const.DB_PRIORITY_2 then
				print("Q1 begin")
				c_priority = c_priority + 1
				local co = priority_queue[c_priority].co
				skynet.wait()
				print("Q1 end")
			end
		end
	end
end

local function query_mysql2()
	-- body
	while true do
		if c_priority ~= const.DB_PRIORITY_2 then
			skynet.wait()
		end
		local r = Queue.dequeue(Q2) 
		if r then
			local res = db:query(r.sql)
			print(string.format("query %s result=", r.table_name), dump(res))
		else
			if c_priority < const.DB_PRIORITY_3 then
				print("Q2 begin")
				c_priority = c_priority + 1
				local co = priority_queue[c_priority].co
				skynet.wait()
				print("Q2 end")
			end
		end
		skynet.sleep(100)  -- 1s
	end
end

local function query_mysql3()
	-- body
	while true do
		if c_priority ~= const.DB_PRIORITY_3 then
			skynet.wait()
		end
		local r = Queue.dequeue(Q3) 
		if r then
			local res = db:query(r.sql)
			print(string.format("query %s result=", r.table_name), dump(res))
		else
			-- skynet.yield()
			skynet.wait()
		end
		print("Q3 begin")
		skynet.sleep(100 * 5) -- 5s
		print("Q3 end")
	end
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
	cache = connect_redis( conf )
	
	frienddb.getvalue( db , cache )

	Q1 = Queue.new(128)
	Q2 = Queue.new(128)
	Q3 = Queue.new(128)

	co1 = skynet.fork(query_mysql1)
	co2 = skynet.fork(query_mysql2)
	co3 = skynet.fork(query_mysql3)

	priority_queue[const.DB_PRIORITY_1] = { Q = Q1, co = co1}
	priority_queue[const.DB_PRIORITY_2] = { Q = Q2, co = co2}
	priority_queue[const.DB_PRIORITY_3] = { Q = Q3, co = co3}

end)
