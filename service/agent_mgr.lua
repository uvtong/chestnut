package.path = "../cat/?.lua;../lualib/?.lua;" .. package.path
package.cpath = "../lua-cjson/?.so;"..package.cpath
local skynet = require "skynet"
local queue = require "queue"

local agent_len = tonumber(skynet.getenv("maxclient")) or 24
local agent_map = queue.new(agent_len)

local CMD = {}

function CMD.next()
	-- body
	if queue.is_empty(agent_map) then
		error "agent is empty."
	end
	return queue.dequeue(agent_map)
end

function CMD.abandon(addr)
	-- body
	queue.enqueue(agent_map, addr)
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(_,_, command, subcmd, ...)
		local f = CMD[command]
		local r = f(subcmd, ... )
		if r then
			skynet.ret(skynet.pack(r))
		end
	end)
	for i=1,agent_len do
		local addr = skynet.newservice("agent")
		queue.enqueue(agent_map, addr)
	end
end)