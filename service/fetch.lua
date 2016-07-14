-- if client for this node has 
local skynet = require "skynet"
local dc = require "datacenter"

local CMD = {}

function CMD.fetch_area_user(user_id)
	-- body
	if dc.get(user_id) then
	else
	end
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(_,_, command, subcmd, ...)
		-- body
		local f = CMD[command]
		local r = f(subcmd, ... )
		if r then
			skynet.retpack(r)
		end
	end)
end)