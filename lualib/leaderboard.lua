local skynet = require "skynet"
local leaderboards_name = skynet.getenv("leaderboards_name")
local lb = skynet.localname(leaderboards_name)
local _M = {}

function _M.push(id, k)
	-- body
	local rnk = skynet.call(lb, "lua", "push", id, k)
	return rnk
end

function _M.name(rnk)
	-- body
	local name = skynet.call(lb, "lua", "name", rnk)
	return name
end

function _M.ranking(id)
	-- body
	local rnk = skynet.call(lb, "lua", "ranking", id)
	return rnk
end

return _M