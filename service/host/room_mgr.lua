local skynet = require "skynet"
require "skynet.manager"
local skynet_queue = require "skynet.queue"
local pqueue = require "priority_queue"
local rt_room_queue = {}
local uid_agent = {}  -- 

local cs1 = skynet_queue()
local cs2 = skynet_queue()
local cs3 = skynet_queue()

local assert = assert

local function compare(a, b, ... )
	-- body
	return a.size > b.size
end

local noret = {}

local function init( ... )
	-- body
	local rt == (1 << 24 | 1 << 16 | 1 << 8)
	rt_room_queue[rt] = pqueue.new(15, compare)
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
		pqueue.enqueue(q, room)
		room.in_queue = true
	end
	return cs2(func1, q, room)
end

local function dequeue(q, ... )
	assert(q)
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
	assert(q)
	local sz = pqueue.size(q)
	if sz > 0 then
		return dequeue(q)
	else
		local roomid = skynet.newservice("room/room")
		local room = { roomid=roomid, size=0, in_queue=false}
		return room
	end
end

local function enqueue_agent(agent, ... )
	-- body
	assert(agent)
	local uid = agent.uid
	local a = uid_agent[uid]
	if a and a.room then
		return a.room
	else
		local room_type = (0 | rule << 8)
		room_type = room_type | mode << 8
		room_type = room_type | scene << 8
		local q = assert(rt_room_queue[room_type])
		local room = get_room(q)
		agent.room = room
		
		uid_agent[uid] = agent

		incre_room(room)

		if room.size >= 3 then
		else
			enqueue(q, room)
		end
		return room
	end
end

local CMD = {}

function CMD.enqueue(source, uid, rule, mode, scene, ... )
	-- body
	-- jude 
	local agent = {
		source = source,
		uid = uid,
		rule = rule,
		mode = mode,
		scene = scene
	}
	local room = assert(enqueue_agent(agent))
	return room
end

function CMD.dequeue(source, uid, ... )
	-- body
end

-- if a player leave room, others must enqueue
function CMD.leave_room(source, uid, ... )
	-- body
	local agent = assert(uid_agent[uid])
	local room = agent.room
	decre_room(room)
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
	skynet.register ".ROOM_MGR"
end)