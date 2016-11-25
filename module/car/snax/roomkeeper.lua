local skynet = require "skynet"
local skynet_queue = require "skynet.queue"
local snax = require "snax"
local log = require "log"
local waiting_queue = require "waiting_queue"

-- local udpgate
local rooms = {}
local udpgates = {}
local gate_max = 1
local gate_idx = 1
local users = {}
local mgr
local room

local waiting = 1
local limit_waiting = {}
local fen_cs

local function fen(t, total, users, ais, ... )
	-- body
	local room = mgr:dequeue_room()
	room.t = t
	room.room.req.start(snax.self(), t, total, users, ais)
	for i=1,users do
		local agent = mgr:dequeue_agent(t)
		agent.agent.post.enter_room(room.id)
	end
	room.num = 30
	mgr:add_use(room)
end

local function cd( ... )
	-- body
	local function func(waiting, ... )
		-- body
		if limit_waiting[waiting] then
			local num = mgr:get_queue_sz(1)
			fen_cs(fen, 1, 30, num, 30 - num)
		else
		end
	end
	return func(waiting)
end

function accept.enter(addr, uid, t, ... )
	-- body
	local agent = {}
	agent.uid = uid
	agent.agent = snax.bind(addr)
	agent.t = t
	users[uid] = agent
	if t == 1 then -- limit
		if mgr:get_queue_sz(t) == 0 then -- nobody
			waiting = waiting + 1
			limit_waiting[waiting] = true
			skynet.timeout(60, cd)
			mgr:enqueue_agent(t, agent)
		elseif mgr:get_queue_sz(t) >= 30 then
			fen_cs(fen, t, 30, 30, 0)
		else
			mgr:enqueue_agent(t, agent)
		end
	elseif t == 2 then -- circle
		local room
		if mgr:size(t) > 0 then
			local rooms = mgr:get_rooms(t)
			for k,v in pairs(rooms) do
				room = v
				break
			end
		else
			room = mgr:dequeue_room()
			room.t = t
			room.num = 0
		end
		assert(room)
		agent.post.enter_room(room.room)
		room.num = room.num + 1
		mgr:add_use(room)
		if room.num >= 30 then
			mgr:remove(t, room)
			mgr:add_full(t, room)
		end
	end
end

function accept.exit(id, ... )
	-- body
	log.info("room id: %d", id)
	local room = mgr:get_use(id)
	if room.t == 1 then
		mgr:remove_fule(room.t, room)
	elseif room.t == 2 then
		mgr:remove(room.t, room)
	end
	mgr:remove_use(room)
	mgr:enqueue_room(room)
end

function response.apply(roomid)
	log.info("roomid %d", roomid)
	if roomid > 5000 then
		local room = rooms[roomid]
		if room == nil then
			gate_idx = gate_idx + 1 % gate_max
			local gate = udpgates[gate_idx]
			local r = snax.newservice("room", roomid, gate.udpgate.handle)
			r.req.start(snax.self().handle, gate.udpgate.handle, 2, 30, 1, 19)
			room = {}
			room.gate = gate
			room.r = r
			rooms[roomid] = room
			return r.handle, gate.host, gate.port
		else
			-- room.req.start()
			return room.r.handle, room.gate.host, room.gate.port
		end
	else
		assert(false)
		local room = mgr:get_use(roomid)
		if room.gate then
			local gate = room.gate
			return room.room, gate.host, gate.post
		else
			gate_idx = gate_idx + 1 % gate_max
			local gate = udpgates[gate_idx]
			room.gate = gate
			return room.room, gate.host, gate.post
		end
		log.info("roomid %d", roomid)
	end
end

function accept.start( ... )
	-- body
	-- room = mgr:dequeue_room()
	-- room.gate = udpgates[1]
	-- room.room.req.start(snax.self().handle, room.gate.udpgate, 2, 30, 1, 19)

	-- local room = snax.newservice("room", 10000, udpgates[1])
	-- room.req.start(snax.self().handle, udpgates[1].gate, 2, 30, 1, 19)
end

-- todo : close room ?

function init()
	local skynet = require "skynet"
-- todo: we can use a gate pool
	local host = skynet.getenv "udp_host"
	local port = skynet.getenv "udp_port"
	assert(host and port)
	for i=1,gate_max do
		local udpgate = snax.newservice("udpserver", host, port+i)
		local gate = {
			host=host,
			port=port+i,
			udpgate=udpgate,
		}
		udpgates[i] = gate
	end
	-- udpgate = snax.newservice("udpserver", "0.0.0.0", port)
	local arr = {1, 2}
	mgr = waiting_queue.new(true, arr)
	fen_cs = skynet_queue()
end
