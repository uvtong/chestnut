local skynet = require "skynet"
local mc = require ""

local START_SUBSCRIBE = {}

function START_SUBSCRIBE:finish(source, ...)
	-- body
	self:flush_db(const.DB_PRIORITY_1)
	print(string.format("the node agent %d will be finished. you should clean something.", skynet.self()))
	skynet.send(source, "lua", "exit")
end

local function start_subscribe()
	-- body
	local c = skynet.call(".start_service", "lua", "register")
	local c2 = mc.new {
		channel = c,
		dispatch = function (channel, source, cmd, ...)
			-- body
			local f = START_SUBSCRIBE[cmd]
			if f then
				f(env, source, ...)
			end
		end
	}
	c2:subscribe()
end 