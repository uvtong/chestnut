local skynet = require "skynet"
require "skynet.manager"
local skynet_queue = require "skynet.queue"
local queue = require "queue"
local assert = assert
local noret = {}
local rt_room_queue = {}
local rooms
local users = {}

local cs1 = skynet_queue()
local cs2 = skynet_queue()

local function new_room( ... )
	-- body
	local room = skynet.newservice("room/room")
	return room	
end

local function init( ... )
	-- body
	local rule = 1
	local mode = 1
	local scene = 1
	local rt = (scene << 24 | mode << 16 | rule << 8)
	rt_room_queue[rt] = queue()
	rooms = queue()
	for i=1,10 do
		local room = new_room()
		enqueue_room(room)
	end
end

local function enqueue_agent(q, agent, ... )
	-- body
	assert(q and agent)
	local function func1(q, i, ... )
		-- body
		q:enqueue(i)
	end
	return cs1(func1, q, agent)
end

local function dequeue_agent(q, ... )
	-- body
	assert(q)
	local function func1(q, ... )
		-- body
		return q:dequeue()
	end
	return cs1(func1, q)
end

local function del_agent(q, agent, ... )
	-- body
	assert(q and agent)
	local function func1(q, agent, ... )
		-- body
		return q:del(agent)
	end
	return cs1(func1, q, agent)
end

local function enqueue_room(room, ... )
	-- body
	assert(room)
	local function func1(q, room, ... )
		-- body
		q:enqueue(room)
	end
	return cs2(func1, rooms, room)
end

local function dequeue_room( ... )
	local function func1(q, ... )
		-- body
		if q:size() > 0 then
			return q:dequeue()
		else
			local room = new_room()
			return room
		end
	end
	return cs2(func1, rooms)
end

local CMD = {}

function CMD.enqueue_agent(source, uid, rule, mode, scene, ... )
	-- body
	local agent = {
		agent = source,
		uid = uid,
		rt = rt,
		rule = rule,
		mode = mode,
		scene = scene,
	}
	users[uid] = agent

	local rt = (scene << 24 | mode << 16 | rule << 8)
	local q = assert(rt_room_queue[rt])
	enqueue_agent(q, agent)
	if q:size() >= 3 then
		local room = dequeue_room()
		skynet.call(room, "lua", "start", rule, mode, scene)
		local agents = {}
		for i=1,3 do
			local agent = dequeue_agent(q)
			users[agent.uid] = nil
			table.insert(agents, agent)
		end
		skynet.call(room, "lua", "enter_room", agents)
	end
	return noret
end

function CMD.dequeue_agent(source, uid, ... )
	-- body
	if users[uid] then
		users[uid] = nil
		local q = rt_room_queue[agent.rt]
		del_agent(q, agent)
	end
end

-- room exit
function CMD.enqueue_room(source, room, ... )
	-- body
	enqueue_room(room)
	return noret
end

function CMD.start(source, ... )
	-- body
	init()
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