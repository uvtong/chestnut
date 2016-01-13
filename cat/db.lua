local skynet = require "skynet"
local mysql = require "mysql"
local redis = require "redis"

local cache
local x = 1
local db

local function connect_mysql( ... )
	-- body
	local function on_connect(db)
		db:query("set charset utf8");
	end
	local db=mysql.connect({
		host="127.0.0.1",
		port=3306,
		database="mysql",
		user="root",
		password="yulei",
		max_packet_size = 1024 * 1024,
		on_connect = on_connect
	})
	return db
end

local function disconnect_mysql( db )
	-- body
	db:disconnect()
end

local conf = {
	host = "127.0.0.1",
	prot = 6379,
	db = 0,
}

local function watching()
	-- body
	local w = redis.watch(conf)
	w:subscribe "foo"
	w:psubscribe "hello.*"
	while true do
		print("watch", w:message())
	end
end

local function connect_redis( ... )
	-- body
	skynet.fork(watching)
	local db = redis.connect(conf)
	return db
end

local function disconnect_redis( cache )
	-- body
	cache:disconnect()
end

local function set(db, cache, table, column, pk, value )
	-- body
	assert(type(value) ~= "userdata")
	local key = string.format("%s_%s_%s", table, pk, column)
	cache:set(key, value)
	local function co( ... )
		-- body, default 'id' is primary key.
		local sql = string.format('update %s set %s = "%s" where id = "%s"', table, column, value, pk)	
		local res = db:query(sql)
	end
	skynet.fork(co)
end

local function get(db, cache, table, column, pk )
	-- body
	local key = string.format('%s_%s_%s', table, pk, column)
	return cache:get(key)
end

local function insert(db, cache, table, values )
	-- body
end

local function load(db, cache, table )
	-- body
	local sql = string.format('')
	res = db:query(sql)
end

local function delete(db, cache, table)
	--TODO
end

local CMD = {}

function CMD:command( ... )
	-- body
	local key = tostring(...)
	return cache:get(key)
end

function CMD:disconnect_redis( ... )
	-- body
	disconnect_redis(cache)
end

function CMD:disconnect_mysql( ... )
	-- body
	disconnect_mysql(db)
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function ( _, _, cmd, ... )
		-- body
		local f = assert(CMD[cmd])
		skynet.ret(skynet.pack(f(...)))
	end)
	db = connect_mysql()
	cache = connect_redis()
end)
