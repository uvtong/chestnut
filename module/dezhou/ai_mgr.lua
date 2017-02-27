local skynet = require "skynet"
require "skynet.manager"
local skynet_queue = require "skynet.queue"
local queue = require "queue"

local cs = skynet_queue()
local leisure_ai = queue()

local function enqueue(id, ... )
	-- body
	leisure_ai:enqueue(id)
end

local function dequeue( ... )
	-- body
	if queue.size(leisure_ai) > 0 then
		return leisure_ai:dequeue()
	else
		return new_ai()
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
	local res = skynet.call(".UID_MGR", "lua", "ai")
	for i=res.min,res.max do
		enqueue(i)
	end
	return true
end

function CMD.close( ... )
	-- body
	return true
end

function CMD.kill( ... )
	-- body
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(_,_, cmd, subcmd, ...)
		local f = CMD[cmd]
		local r = f(subcmd, ... )
		if r ~= nil then
			skynet.ret(skynet.pack(r))
		end
	end)
	skynet.register ".AI_MGR"
end)
