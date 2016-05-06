local skynet = require "skynet"
local wdb = skynet.localname(".wdb")
local rdb = skynet.localname(".rdb")

local _M = {
	DB_PRIORITY_1 = 1,
	DB_PRIORITY_2 = 2,
	DB_PRIORITY_3 = 3
}

function _M.write(table_name, sql, priority)
	-- body
	skynet.send(wdb, "lua", "command", "write", table_name, sql, priority)
end

function _M.read(table_name, sql)
	-- body
	return skynet.call(rdb, "lua", "command", "read", table_name, sql)
end

function _M.set(k, v)
	-- body
	skynet.send(wdb, "lua", "command", "set", k, v)
end
	
function _M.get(k, sub)
	-- body
	return skynet.call(rdb, "lua", "command", "get", k, sub)
end

return _M