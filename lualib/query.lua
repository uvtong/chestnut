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
	print(rdb)
	local r = skynet.call(rdb, "lua", "command", "read", table_name, sql)
	return r
end

function _M.set(wdb, k, v)
	-- body
	skynet.send(wdb, "lua", "command", "set", k, v)
end
	
function _M.get(rdb, k, sub)
	-- body
	return skynet.call(rdb, "lua", "command", "get", k, sub)
end

return _M