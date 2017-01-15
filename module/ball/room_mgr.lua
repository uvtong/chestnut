local skynet = require "skynet"
require "skynet.manager"
local queue = require "queue"
local log = require "log"

local id = 1
local rooms = {}
local q

local cmd = {}

function cmd.start( ... )
	-- body
	q = queue()
	for i=1,10 do
		id = id + 1
		local room = skynet.newservice("room/room", id)
		rooms[id] = room
		q:enqueue { addr=room, id=id}
		
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
		id = id + 1
		local room = skynet.newservice("room/room", id)
		rooms[id] = room
		return { addr=room, id=id}
	end
end

function cmd.exit(room, ... )
	-- body
	q:enqueue(room)
end

function cmd.apply(id, ... )
	-- body
	return rooms[id]
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
	skynet.register ".ROOM_MGR"
end)

