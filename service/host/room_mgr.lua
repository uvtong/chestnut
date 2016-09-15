local skynet = require "skynet"
require "skynet.manager"
local queue = require "queue"
local qt = {}
local uid_agent = {}
local uid_room = {}
local frontrooms = {}
local backrooms = {}
local noret = {}

local function init( ... )
	-- body
	local room_type == (1 << 24 | 1 << 16 | 1 << 8)
	qt[room_type] = queue.new(10)
end

local function exchange( ... )
	-- body
	if #frontrooms == 0 then
		if #backrooms > 0 then
			local tmp = frontrooms
			frontrooms = backrooms
			backrooms = tmp
			return true
		else
			return false
		end
	else
		return false
	end
end

local function newroom( ... )
	-- body
	local roomid = skynet.newservice("room")
	return roomid
end

local function get_roomid( ... )
	-- body
	local sz = #frontrooms
	if sz > 0 then
		local roomid = frontrooms[sz]
		frontrooms[sz] = nil
		return roomid
	else
		if exchange() then
			sz = #frontrooms
			local roomid = frontrooms[sz]
			frontrooms[sz] = nil
			return roomid
		else
			return newroom()
		end
	end
end

local CMD = {}

function CMD.enqueue(source, uid, rule, mode, scene, ... )
	-- body
	local roomid = uid_room[uid]
	if roomid then
	else
		local room_type = (0 | rule << 8)
		room_type = room_type | mode << 8
		room_type = room_type | scene << 8
		local q = assert(qt[room_type])
		local agent = {
			source = source,
			uid = uid,
			rule = rule,
			mode = mode,
			scene = scene
		}
		queue.enqueue(q, agent)
		local sz = queue.size(q)
		if sz >= 3 then
			-- fen
			local roomid = get_roomid()
			for i=1,2 do
				local agent = queue.dequeue(q)
				
				skynet.call(roomid, "lua", "enter_room", )
			end
			if #frontrooms > 0 then
		end

		if room_type == (1 << 24 | 1 << 16 | 1 << 8) then
			table.insert(p0_rooms, uid)
			local sz = #p0_rooms
			if sz >= 3 then
				local roomid = get_roomid()
				-- 
			end
		end
	end

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

function CMD.leave_room(source, uid, ... )
	-- body

end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function (_, source, cmd, ... )
		-- body
		local f = assert(CMD[cmd])
		local r = f(source, ...)
		if r ~= noret then
			skynet.retpack(r)
		end
	end)
	skynet.register ".ROOM_MGR"
end)