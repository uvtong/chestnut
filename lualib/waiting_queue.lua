local skynet = require "skynet"
local skynet_queue = require "skynet.queue"
local snax = require "snax"
local queue = require "queue"
local cls = class("waiting_queue")

function cls:ctor(usnax, arr, ... )
	-- body
	assert(usnax and arr)
	self._usnax = usnax
	
	
	self._id = 0
	self._rooms = queue()  -- freelist

	self._trooms = {}
	self._trooms_sz = {}
	self._tfullrooms = {}
	self._tfullrooms_sz = {}

	self._queues = {}
	-- types
	for i,v in ipairs(arr) do
		self._queues[v] = queue()
		self._trooms[v] = {}
		self._trooms_sz[v] = 0
		self._tfullrooms[v] = {}
		self._tfullrooms_sz[v] = 0
	end
	
	self._cs1 = skynet_queue()  -- agent
	self._cs2 = skynet_queue()  -- room
	
	self._use = {}
	self._use_sz = 0
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

function cls:get_agent_queue_sz(t, ... )
	-- body
	local q = self._queues[t]
	return q:size()
end

function cls:create_room( ... )
	-- body
	self._id = self._id + 1
	local room
	if self._usnax then
		room = snax.newservice("room", self._id, skynet.self())
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
			local room = q:dequeue()
			return room
		else
			local room = self:create_room()
			return room
		end
	end
	return self._cs2(func1, self._rooms)
end

-- normal 
function cls:add(t, room, ... )
	-- body
	assert(t and room)
	if self._trooms[t][room.id] then
	else
		self._trooms[t][room.id] = room
		self._trooms_sz[t] = self._trooms_sz[t] + 1
	end
end

function cls:remove(t, room, ... )
	-- body
	if self._trooms[t][room.id] then
		self._trooms[t][room.id] = nil
		self._trooms_sz[t] = self._trooms_sz[t] - 1
	else
	end
end

function cls:size(t, ... )
	-- body
	return self._trooms_sz[t]
end

function cls:get_room(t, id, ... )
	-- body
	return self._trooms[t][id]
end

function cls:get_rooms(t, ... )
	-- body
	return self._trooms[t]
end

-- full
function cls:add_full(t, room, ... )
	-- body
	assert(t and room)
	if self._tfullrooms[t][room.id] then
	else
		self._tfullrooms[t][room.id] = room
		self._tfullrooms_sz[t] = self._tfullrooms_sz[t] + 1
	end
end

function cls:remove_fule(t, room, ... )
	-- body
	if self._tfullrooms[t][room.id] then
		self._tfullrooms[t][room.id] = nil
		self._tfullrooms_sz[t] = self._tfullrooms_sz[t] - 1
	else
	end
end

function cls:size_full(t, ... )
	-- body
	return self._tfullrooms_sz[t]
end

function cls:get_full_room(t, id, ... )
	-- body
	return self._tfullrooms[t][id]
end

function cls:get_full_rooms(t, ... )
	-- body
	return self._tfullrooms[t]
end

-- use
function cls:add_use(room, ... )
	-- body
	assert(self._use[room.id] == nil)
	self._use[room.id] = room
	self._use_sz = self._use_sz + 1
end

function cls:remove_use(room, ... )
	-- body
	if self._use[room.id] then
		self._use[room.id] = nil
		self._use_sz = self._use_sz - 1
	end
end

function cls:get_use(id, ... )
	-- body
	return self._use[id]
end

return cls