local snax = require "snax"
local log = require "log"

-- local udpgate
local rooms = {}
local udpgates = {}
local gate_max = 1
local gate_idx = 1


function response.apply(roomid)
	log.info("roomid %d", roomid)
	local room = rooms[roomid]
	if room == nil then

		gate_idx = gate_idx + 1 % gate_max
		local gate = udpgates[gate_idx]
		local r = snax.newservice("room", roomid, gate.udpgate.handle)
		r.req.start()
		room = {}
		room.gate = gate
		room.r = r
		rooms[roomid] = room
		return r.handle, gate.host, gate.port
	else
		-- room.req.start()
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
		local udpgate = snax.newservice("udpserver", host, port+i)
		local gate = {
			host=host,
			port=port+i,
			udpgate=udpgate,
		}
		udpgates[i] = gate
	end
	-- udpgate = snax.newservice("udpserver", "0.0.0.0", port)
end
