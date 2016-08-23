local skynet = require "skynet"
require "skynet.manager"
local p0_rooms = {}
local p1_rooms = {}
local p2_rooms = {}
local uid_map = {}

local CMD = {}

function CMD.enqueue(source, uid, ... )
	-- body
	uid_map[uid] = source
	local room
	if #p2_rooms > 0 then
		room = p2_rooms[1]
		local sz = #p2_rooms
		for i=2,sz do
			p2_rooms[i-1] = p2_rooms[i]
			if i == sz then
				p2_rooms[i] = nil
			end
		end
	elseif #p1_rooms > 0 then
		room = p1_rooms[1]
		local sz = #p1_rooms
		for i=2,sz do
			p1_rooms[i-1] = p1_rooms[i-1]
			if i == sz then
				p1_rooms[i] = nil
			end
		end
	elseif #p0_rooms > 0 then
		room = p0_rooms[1]
		local sz = #p0_rooms
		for i=2,sz do
			p0_rooms[i-1] = p0_rooms[i-1]
			if i == sz then
				p0_rooms[i] = nil
			end
		end
	else
		local addr = skynet.newservice("room/room")
		table.insert(p1_rooms, addr)
		return addr
	end
	return room
end

function CMD.dequeue(source, uid, ... )
	-- body
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function (_, source, cmd, ... )
		-- body
		local f = assert(CMD[cmd])
		local r = f(source, ...)
		if r ~= nil then
			skynet.retpack(r)
		end
	end)
	skynet.register ".ROOM_MGR"
end)