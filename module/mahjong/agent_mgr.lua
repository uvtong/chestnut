local skynet = require "skynet"
require "skynet.manager"
local snax = require "snax"
local queue = require "queue"

local leisure_agent = queue.new(16)
local handle_agent = {}

local CMD = {}

function CMD.enter(uid, fd)
	-- body
	if queue.is_empty(leisure_agent) then
		local a = snax.newservice("agent")
		handle_agent[a.handle] = a
		return a.handle
	else
		local a = queue.dequeue(leisure_agent)
		handle_agent[a.handle] = a
		return a.handle
	end
end

function CMD.abandon(addr)
	-- body
	local a = handle_agent[addr]
	queue.enqueue(leisure_agent, a)
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