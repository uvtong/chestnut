local snax = require "snax"

-- local udpgate
local rooms = {}
local udpgates = {}
local gate_max = 1
local gate_idx = 1

function accept.enter( ... )
	-- body
end

function accept.exit( ... )
	-- body
end

function accept.enter_room( ... )
	-- body
end

function response.apply(roomid)
	local room = rooms[roomid]
	if room == nil then
		gate_idx = gate_idx + 1 % gate_max
		local gate = udpgates[gate_idx]
		local r = snax.newservice("room", roomid, gate.udpgate.handle)
		room = {}
		room.gate = gate
		room.r = r
		rooms[roomid] = room
		return r.handle, gate.host, gate.port
	else
		return room.r.handle, room.gate.host, room.gate.port
	end
end

-- todo : close room ?

function init()
	local skynet = require "skynet"
-- todo: we can use a gate pool
	local host = skynet.getenv "udp_host"
	local port = skynet.getenv "udp_port"
	assert(host and port)
	for i=1,gate_max do
		local xport = port + i
		local udpgate = snax.newservice("udpserver", host, xport)
		local gate = {
			host=host,
			port=xport,
			udpgate=udpgate,
		}
		udpgates[i] = gate
	end
	-- udpgate = snax.newservice("udpserver", "0.0.0.0", port)
end
