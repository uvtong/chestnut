local skynet = require "skynet"
require "skynet.manager"
local queue = require "queue"
local udpserver = require "udpserver"

local gate_max = 10
local q

local cmd = {}

function cmd.start( ... )
	-- body
	local host = skynet.getenv "udp_host"
	local port = skynet.getenv "udp_port"
	q = queue()
	for i=1,gate_max do
		local xport = port + i
		local udpgate = skynet.newservice("udpserver")
		skynet.call(udpgate, "lua", "start", host, xport)
		q:enqueue(udpgate)
	end
	return true
end

function cmd.close( ... )
	-- body
	return true
end

function cmd.kill( ... )
	-- body
	skynet.exit()
end

function cmd.enter( ... )
	-- body
	print("xxx")
	local udpgate = q:dequeue()
	print(udpgate)
	q:enqueue(udpgate)
	return udpgate
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function(_,_, command, subcmd, ...)
		local f = cmd[command]
		local r = f(subcmd, ... )
		if r ~= nil then
			skynet.ret(skynet.pack(r))
		end
	end)
	skynet.register ".UDPSERVER_MGR"
end)