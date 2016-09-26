local skynet = require "skynet"

local _M = {
	DB_PRIORITY_1 = 1,
	DB_PRIORITY_2 = 2,
	DB_PRIORITY_3 = 3
}

function _M.write(wdb, table_name, sql, priority)
	-- body
	skynet.send(wdb, "lua", "command", "write", table_name, sql, priority)
end

function _M.read(rdb, table_name, sql)
	-- body
	print(table_name, sql)
	assert(false, table_name, sql)
	if type(rdb) == "string" then
		if not string.match(rdb, "^%.[%w_]*") then
			error(string.format("read data from %s", table_name))
		end
	else
		assert(type(rdb) == "number")
	end
	local r = skynet.call(rdb, "lua", "command", "read", table_name, sql)
	return r
end

function _M.set(wdb, k, v)
	-- body
	skynet.send(wdb, "lua", "command", "set", k, v)
end

function _M.hset(wdb, k, kk, vv)
	-- body
	skynet.send(wdb, "lua", "command", "hset", k, kk, vv)
end

function _M.get(rdb, k, sub)
	-- body
	return skynet.call(rdb, "lua", "command", "get", k, sub)
end

function _M.hget(rdb, k, ... )
	-- body
	return skynet.call(rdb, "lua", "command", "hget", k)
end

return _M