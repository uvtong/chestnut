local skynet = require "skynet"
local queue = require "queue"
local log = require "log"

local q

local cmd = {}

function cmd.start( ... )
	-- body
	q = queue()
	for i=1,10 do
		local room = skynet.newservice("room/room")
		q:enqueue(room)
	end
	return true
end

function cmd.close( ... )
	-- body
	return true
end

function cmd.kill( ... )
	-- body
end

function cmd.enter( ... )
	-- body
	if #q > 0 then
		return q:dequeue()
	else
		return skynet.newservice("room/room")
	end
end

function cmd.exit(room, ... )
	-- body
	q:enqueue(room)
end

-- todo : close room ?

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function(_,_, command, subcmd, ...)
		local f = cmd[command]
		local r = f(subcmd, ... )
		if r ~= nil then
			skynet.ret(skynet.pack(r))
		end
	end)	
end)

