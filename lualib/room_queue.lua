local skynet = require "skynet"
local skynet_queue = require "skynet.queue"
local snax = require "snax"
local queue = require "queue"
local cls = class("room_queue")

function cls:ctor(usnax, arr, ... )
	-- body
	assert(usnax and arr)
	self._usnax = usnax
	self._queues = {}
	-- types
	for i,v in ipairs(arr) do
		self._queues[v] = queue()	
	end
	
	self._rooms = queue()
	self._use = {}
	self._id = 0

	self._cs1 = skynet_queue()
	self._cs2 = skynet_queue()
	
end

function cls:enqueue_agent(t, agent, ... )
	-- body
	local q = self._queues[t]
	local function func1(q, i, ... )
		-- body
		q:enqueue(i)
	end
	return self._cs1(func1, q, agent)
end

function cls:dequeue_agent(t, ... )
	-- body
	local q = self._queues[t]
	local function func1(q, ... )
		-- body
		return q:dequeue()
	end
	return self._cs1(func1, q)
end

function cls:del_agent(t, agent, ... )
	-- body
	local q = self._queues[t]
	local function func1(q, agent, ... )
		-- body
		return q:del(agent)
	end
	return self._cs1(func1, q, agent)
end

function cls:get_queue_sz(t, ... )
	-- body
	local q = self._queues[t]
	return q:size()
end

function cls:create_room( ... )
	-- body
	self._id = self._id + 1
	local room
	if self._usnax then
		room = snax.newservice("snax/room")
	else
		room = skynet.newservice("room/room")
	end
	assert(room)
	local x = {
		id = self._id,
		room = room,
		num = 0
	}
	return x
end

function cls:enqueue_room(room, ... )
	-- body
	local function func1(q, room, ... )
		-- body
		q:enqueue(room)
	end
	return self._cs2(func1, self._rooms, room)
end

function cls:dequeue_room( ... )
	-- body
	local function func1(q, ... )
		-- body
		if q:size() > 0 then
			return q:dequeue()
		else
			local room = self:create_room()
			return room
		end
	end
	return self._cs2(func1, self._rooms)
end

function cls:get_use_room(id, ... )
	-- body
	return self._use[id]
end

function cls:set_use_room_num(id, num, ... )
	-- body
	local room = self._use[id]
	room.num = num
end

return cls