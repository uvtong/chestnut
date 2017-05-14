local skynet = require "skynet"
require "skynet.manager"
local skynet_queue = require "skynet.queue"
local queue = require "queue"
local errorcode = require "errorcode"

local cs = skynet_queue()

local leisure_agent = queue()
local users = {}

local function new_agent( ... )
	-- body
	local addr = skynet.newservice("agent/agent")
	return addr
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

local CMD = {}

function CMD.start(t, ... )
	-- body
	for i=1,10 do
		local agent = new_agent()
		enqueue(agent)
	end
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
	local addr = users[uid]
	if addr then
		skynet.call(addr, "lua", "start", false)
	else
		local addr = cs(dequeue)
		skynet.call(addr, "lua", "start", true)
		users[uid] = addr
		return addr
	end
end

function CMD.exit(uid)
	-- body
	assert(uid)
	local addr = users[uid]
	assert(addr)
	skynet.timeout(100 * 60 * 60 * 24 * 5, function ( ... )
		-- body
		local addr = users[uid]
		assert(addr)
		users[uid] = nil
		cs(enqueue, addr)	
	end)
	return errorcode.SUCCESS
end

function CMD.exit_at_once(uid, ... )
	-- body
	assert(uid)
	local addr = users[uid]
	assert(addr)
	users[uid] = nil
	cs(enqueue, addr)
	return errorcode.SUCCESS
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
