local skynet = require "skynet"
require "skynet.manager"
local skynet_queue = require "skynet.queue"
local queue = require "queue"

local cs = skynet_queue()
local agent_service_type = 1   -- 1. snax, 2. normal

local leisure_agent = queue()
local users = {}

local function new_agent( ... )
	-- body
	return skynet.newservice("agent/agent")
end

local function enqueue(agent, ... )
	-- body
	leisure_agent:enqueue(agent)
end

local function dequeue( ... )
	-- body
	if #leisure_agent > 0 then
		return leisure_agent:dequeue()
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

function CMD.start(t, ... )
	-- body
	init()
	return true
end

function CMD.close( ... )
	-- body
	return true
end

function CMD.kill( ... )
	-- body
	skynet.exit()
end

function CMD.enter(uid, ... )
	-- body
	assert(uid)
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
	assert(uid)
	local agent = users[uid]
	assert(agent)
	users[uid] = nil
	cs(enqueue, agent)
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
