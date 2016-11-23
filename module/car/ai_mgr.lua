local skynet = require "skynet"
require "skynet.manager"
local skynet_queue = require "skynet.queue"
local queue = require "lqueue"

local cs = skynet_queue()

local id = 1
local leisure_ai = queue.new(255)

local function new_ai( ... )
	-- body
	id = id + 1
	return id
end

local function enqueue(id, ... )
	-- body
	queue.enqueue(leisure_ai, id)
end

local function dequeue( ... )
	-- body
	if queue.size(leisure_ai) > 0 then
		return queue.dequeue(leisure_ai)
	else
		return new_ai()
	end
end

local function init( ... )
	-- body
	for i=1,10 do
		local id = new_ai()
		enqueue(id)
	end
end

local CMD = {}

function CMD.enter()
	-- body
	return cs(dequeue)
end

function CMD.exit(id)
	-- body
	cs(enqueue, id)
	return true
end

function CMD.start(t, ... )
	-- body
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
	skynet.register ".AI_MGR"
end)
