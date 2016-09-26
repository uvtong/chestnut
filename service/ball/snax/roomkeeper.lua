local snax = require "snax"
local host
local port = 9999
local udpgate
local rooms = {}
local udpgates = {}
local gate_max = 10
local gate_idx = 1


function response.apply(roomid)
	local room = rooms[roomid]
	if room == nil then
		room = snax.newservice("room", roomid, udpgate.handle)
		rooms[roomid] = room
	end
	local gate = udpgates[gate_idx]
	gate_idx = gate_idx + 1
	local host = gate.host
	local port = gate.port
	return room.handle , host, port
end

-- todo : close room ?

function init()
	local skynet = require "skynet"
-- todo: we can use a gate pool
	host = skynet.getenv "udp_host"
	port = skynet.getenv "udp_port"
	for i=1,gate_max do
		local udpgate = snax.newservice("udpserver", host, port+i)
		local gate = {
			host=host,
			port=port+i,
			udpgate=udpgate,
		}
		table.insert(udpgates, gate)
	end
	-- udpgate = snax.newservice("udpserver", "0.0.0.0", port)
end
