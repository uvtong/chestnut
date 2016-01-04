local skynet = require "skynet"
local sprotoloader = require "sprotoloader"

local max_client = 64
local server_name = "sample"
local loginserver = "LOGIND"

skynet.start(function()
	skynet.uniqueservice("protoloader")
	local console = skynet.newservice("console")
	skynet.newservice("debug_console",8000)
	skynet.newservice("simpledb")
	--skynet.uniqueservice("mysql")
	--skynet.uniqueservice("redis")
	--server_name = skynet.getenv("servername")
	gate = skynet.newservice("gated", loginserver)
	skynet.error "run here."
	skynet.call(gate, "lua", "open", { 
		port = 8888,
		maxclient = max_client,
		servername = server_name,
		--nodelay = true,
	})

	--local watchdog = skynet.newservice("watchdog")
	--skynet.call(watchdog, "lua", "start", {
	--	port = 8888,
	--	maxclient = max_client,
	--	servername = server_name,
		--nodelay = true,
	--})
	print (" watchdog listen on ", 8888)
	skynet.exit()
end)
