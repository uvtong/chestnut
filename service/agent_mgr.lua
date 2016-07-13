local skynet = require "skynet"
require "skynet.manger"

local gate
local leisure_agent = {}

local uid_agent = {}
local agent_uid = {}
local uid_fd = {}
local fd_uid = {}

local CMD = {}

function CMD.enter(uid, fd)
	-- body
	if #leisure_agent == 0 then
		local a = skynet.newservice("agent")
		skynet.call(a, "lua", "start", { agent_mgr = skynet.self(), uid = uid, client = fd})
	else
		local r = math.random(1, #leisure_agent)
		local a = leisure_agent[r]
		skynet.call(a, "lua", "start", { agent_mgr = skynet.self(), uid = uid, client = fd})
	end
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