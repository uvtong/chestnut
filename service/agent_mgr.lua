local skynet = require "skynet"
require "skynet.manager"
local queue = require "queue"


local leisure_agent = queue.new(16)


local CMD = {}

function CMD.enter(uid, fd)
	-- body
	if #leisure_agent == 0 then
		local a = skynet.newservice("agent/agent")
		return a
	else
		local a = queue.dequeue(leisure_agent)
		return a
	end
end

function CMD.abandon(addr)
	-- body
	queue.enqueue(leisure_agent, addr)
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(_,_, cmd, subcmd, ...)
		local f = CMD[cmd]
		local r = f(subcmd, ... )
		if r then
			skynet.ret(skynet.pack(r))
		end
	end)
	skynet.register ".AGENT_MGR"
end)