local skynet = require "skynet"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local uid_map = {}
local id_map = {}
local env

local UDPMSG = {}

function UDPMSG:transform(source, ... )
 	-- body
 	for k,v in pairs(id_map) do
 		if k ~= source then
 			local address = socket.udp_address(v.addr, v.port)
 			socket.sendto(k, v.addr, address, ...)
 		end
 	end
 end 

local function udpdispatch( ... )
	-- body
end

local CMD = {}

function CMD:enter(uid, addr, port, ... )
	-- body
	local host = "127.0.0.1"
	local port = skynet.call(".wgame", "lua", "udp_port")
	local id = socket.udp(udpdispatch, host, port)
	uid_map[uid] = id
	id_map[id] = { 
		uid = uid,
		addr = addr,
		port = port,
	}
	return port
end

function CMD:exit( ... )
	-- body
end

function CMD:afk( ... )
	-- body

end

skynet.start(function()
	skynet.dispatch("lua", function (_, source, cmd, ... )
		-- body
		local f = CMD[cmd]
		local r = f(env, source, ... )
		if r then
			skynet.retpack(r)
		end
	end)
end)