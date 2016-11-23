local skynet = require "skynet"
require "skynet.manager"
local snax = require "snax"
local skynet_queue = require "skynet.queue"
local queue = require "lqueue"

local cs = skynet_queue()
local agent_service_type = 1   -- 1. snax, 2. normal

local leisure_agent = queue.new(255)
local users = {}

local function new_agent( ... )
	-- body
	if agent_service_type == 1 then
		local agent = snax.newservice("agent")
		return agent.handle
	else
		local agent = skynet.newservice("agent")
		return agent
	end
end

local function enqueue(agent, ... )
	-- body
	queue.enqueue(leisure_agent, agent)
end

local function dequeue( ... )
	-- body
	if queue.size(leisure_agent) > 0 then
		return queue.dequeue(leisure_agent)
	else
		return new_agent()
	end
end

local function init( ... )
	-- body
	for i=1,10 do
		local agent = new_agent()
		enqueue(agent)
	end
end

local CMD = {}

function CMD.enter(uid, fd)
	-- body
	if users[uid] then
		return users[uid]
	else
		local agent = cs(dequeue)
		users[uid] = agent
		return agent
	end
end

function CMD.exit(uid)
	-- body
	local agent = users[uid]
	assert(agent)
	users[uid] = nil
	cs(enqueue, agent)
	return true
end

function CMD.start(t, ... )
	-- body
	agent_service_type = t
	init()
	return true
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
