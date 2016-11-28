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
	log.info("fen begin. ais:%d", ais)
	gate_idx = gate_idx + 1 % gate_max
	local gate = udpgates[gate_idx]
	local room = mgr:dequeue_room()
	room.t = t
	room.num = users
	room.gate = gate
	room.room.req.start(snax.self().handle, gate.udpgate.handle, t, total, users, ais)
	for i=1,users do
		local agent = mgr:dequeue_agent(t)
		agent.agent.post.enter_room(room.id)
	end
	
	mgr:add_full(t, room)
	mgr:add_use(room)
end

local function cd( ... )
	-- body
	log.info("abc")
	local function func(waiting, ... )
		-- body
		if limit_waiting[waiting] then
			local num = mgr:get_agent_queue_sz(1)
			fen_cs(fen, 1, 30, num, (20 - num and (20 -num) or 0))
		else
		end
	end
	func(waiting)
end

function accept.enter(addr, uid, t, ... )
	-- body
	local agent = {}
	agent.uid = uid
	agent.agent = snax.bind(addr, "agent")
	agent.t = t
	users[uid] = agent
	if t == 1 then -- limit
		mgr:enqueue_agent(t, agent)
		if mgr:get_agent_queue_sz(t) == 1 then -- nobody
			log.info("test 0")
			waiting = waiting + 1
			limit_waiting[waiting] = true
			skynet.timeout(600 * 1, cd)
		elseif mgr:get_agent_queue_sz(t) >= 30 then
			log.info("test 1")
			fen_cs(fen, t, 30, 30, 0)
		else
			log.info("test 2")
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
			gate_idx = gate_idx + 1 % gate_max
			local gate = udpgates[gate_idx]
			room = mgr:dequeue_room()
			room.t = t
			room.num = 0
			room.gate = gate
			room.room.req.start(snax.self().handle, gate.udpgate.handle, t, 30, 1, 19)
		end
		assert(room)
		agent.agent.post.enter_room(room.id)
		mgr:add_use(room)

		room.num = room.num + 1
		if room.num >= 30 then
			mgr:add_full(t, room)
		else
			mgr:add(t, room)
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
			r.req.start(snax.self().handle, gate.udpgate.handle, 2, 30, 1, 1)
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
		local room = mgr:get_use(roomid)
		log.info("roomid %d, type: %d", room.id, room.t)
		if room.gate then
			local gate = room.gate
			return room.room.handle, gate.host, gate.post
		else
			gate_idx = gate_idx + 1 % gate_max
			local gate = udpgates[gate_idx]
			room.gate = gate
			return room.room.handle, gate.host, gate.post
		end
	end
end

function response.start( ... )
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
