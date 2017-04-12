local skynet = require "skynet"

local _M = {}

function _M.select(table_name, sql)
	-- body
	return skynet.call(".DB", "lua", "query", "select", table_name, sql)
end

function _M.update(table_name, sql)
	-- body
	skynet.send(".DB", "lua", "query", "update", table_name, sql)
end

function _M.insert(table_name, sql, ... )
	-- body
	skynet.send(".DB", "lua", "query", "insert", table_name, sql)
end

function _M.get(k, sub)
	-- body
	return skynet.call(".DB", "lua", "query", "get", k, sub)
end

function _M.hget(k, ... )
	-- body
	return skynet.call(".DB", "lua", "query", "hget", k)
end

function _M.set(k, v)
	-- body
	skynet.send(".DB", "lua", "query", "set", k, v)
end

function _M.hset(k, kk, vv)
	-- body
	skynet.send(".DB", "lua", "query", "hset", k, kk, vv)
end

return _M