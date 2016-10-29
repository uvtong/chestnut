local skynet = require "skynet"
require "skynet.manager"
local skynet_queue = require "skynet.queue"
local queue = require "queue"
local assert = assert
local noret = {}
local rt_room_queue = {}
local rooms

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
	rooms = queue.new(0)
end

local function enqueue_agent(q, agent, ... )
	-- body
	assert(agent)
	local function func1(q, i, ... )
		-- body
		queue.enqueue(q, i)
	end
	return cs1(func1, q, agent)
end

local function dequeue_agent(q, ... )
	-- body
	local function func1(q, i, ... )
		-- body
		return queue.dequeue(q, i)
	end
	return cs1(func1, q)
end

local function enqueue_room(room, ... )
	-- body
	assert(room)
	local function func1(q, room, ... )
		-- body
		queue.enqueue(q, room)
	end
	return cs2(func1, rooms, room)
end

local function dequeue_room(room, ... )
	assert(room)
	local function func1(q, ... )
		-- body
		if queue.size(q) > 0 then
			local room = queue.dequeue(q)
			return room
		else
			local room = skynet.newservice("room/room")
			return room	
		end
	end
	return cs2(func1, q)
end

local CMD = {}

function CMD.enqueue_agent(source, uid, rule, mode, scene, ... )
	-- body
	local rt = (scene << 24 | mode << 16 | rule << 8)
	local agent = {
		agent = source,
		uid = uid,
		rt = rt
	}
	local q = assert(rt_room_queue[rt])
	enqueue_agent(q, agent)
	if queue.size(q) >= 3 then
		local room = dequeue_room(rooms)
		skynet.call(room, "lua", "start", rule, mode, scene)
		local agents = {}
		for i=1,3 do
			local agent = dequeue(q)
			table.insert(agents, agent)
		end
		skynet.call(room, "lua", "enter_room", agents)
	end
	return noret
end

function CMD.enqueue_room(room, ... )
	-- body
	enqueue_room(rooms, room)
	return noret
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