local skynet = require "skynet"
local _M = {}

function _M.poll(cnt, viewed, ... )
	-- body
	return skynet.call(".SYSEMAIL", "lua", "poll", cnt, viewed)
end

function _M.get(id, ... )
	-- body
	return skynet.call(".SYSEMAIL", "lua", "get", id)
end

return _M