local skynet = require "skynet"

-- local udpgate
local rooms = {}
local udpgates = {}
local gate_max = 1
local gate_idx = 1

local cmd = {}

function cmd.start( ... )
	-- body
	return true
end

function cmd.close( ... )
	-- body
	return true
end

function cmd.kill( ... )
	-- body
end


function cmd.enter( ... )
	-- body
end

function cmd.exit( ... )
	-- body
end

function cmd.apply(roomid)
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

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function(_,_, command, subcmd, ...)
		local f = cmd[command]
		local r = f(subcmd, ... )
		if r ~= nil then
			skynet.ret(skynet.pack(r))
		end
	end)

	local host = skynet.getenv "udp_host"
	local port = skynet.getenv "udp_port"
	assert(host and port)
	for i=1,gate_max do
		local xport = port + i
		local udpgate = skynet.newservice("udpserver")
		skynet.call(udpgate, "lua", "start", host, xport)
		local gate = {
			host=host,
			port=xport,
			udpgate=udpgate,
		}
		udpgates[i] = gate
	end
end)

