local skynet = require "skynet"
require "skynet.manager"
local skynet_queue = require "skynet.queue"
local queue = require "queue"
local assert = assert

local noret = {}
local rt_room_queue = {}
local users = {}  -- uid -> agent ->room

local cs1 = skynet_queue()
local cs2 = skynet_queue()
local cs3 = skynet_queue()

local function init( ... )
	-- body
	local rule = 1
	local mode = 1
	local scene = 1
	local rt = (scene << 24 | mode << 16 | rule << 8)
	rt_room_queue[rt] = queue.new(15)
end

local function incre_room(room, ... )
	-- body
	assert(room)
	local function func1(room, ... )
		-- body
		room.size = room.size + 1
		assert(room.size >= 0)
	end
	return cs1(func1, room)
end

local function decre_room(room, ... )
	-- body
	assert(room)
	local function func1(room, ... )
		-- body
		room.size = room.size - 1
		assert(room.size <= 3)
	end
	return cs1(func1, room)
end

local function enqueue(q, room, ... )
	-- body
	assert(q and room)
	local function func1(q, room, ... )
		-- body
		queue.enqueue(q, room)
		room.in_queue = true
	end
	return cs2(func1, q, room)
end

local function dequeue(q, ... )
	assert(q)
	assert(pqueue.size(q) > 0)
	local function func1(q, ... )
		-- body
		local room = pqueue.dequeue(q)
		room.in_queue = false
		return room
	end
	return cs2(func1, q)
end

local function get_room(q, ... )
	-- body
	local sz = queue.size(q)
	if sz > 0 then
		local room = queue.peek(q)
		assert(room)
		return room
	else
		local roomid = skynet.newservice("room/room")
		local room = { roomid=roomid, size=0, in_queue=false}
		enqueue(q, room)
		return room
	end
end

local CMD = {}

function CMD.enqueue(source, uid, rule, mode, scene, ... )
	-- body
	
	local agent = {
		agent = source,
		uid = uid,
		rule = rule,
		mode = mode,
		scene = scene
	}
	assert(users[uid] == nil)
	users[uid] = agent
	local rt = (scene << 24 | mode << 16 | rule << 8)
	local q = assert(rt_room_queue[rt])
	local room = get_room(q)
	if room.size >= 3 then
		dequeue(q, room)
	end
	agent.room = room
	return room.roomid
end

function CMD.dequeue(source, uid, ... )
	-- body
	assert(false)
end

-- if a player leave room, others must enqueue
function CMD.leave_room(source, uid, ... )
	-- body
	local agent = assert(uid_agent[uid])
	local room = agent.room
	decre_room(room)
	users[uid] = nil
	return true
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
	init()
	skynet.register ".ROOM_MGR"
end)