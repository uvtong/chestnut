local skynet = require "skynet"
local sprotoloader = require "sprotoloader"

local max_client = 64
local server_name = "sample"

skynet.start(function()
	skynet.uniqueservice("protoloader")
	local console = skynet.newservice("console")
	skynet.newservice("debug_console",8000)
	skynet.newservice("simpledb")
	--skynet.uniqueservice("mysql")
	--skynet.uniqueservice("redis")
	--server_name = skynet.getenv("servername")
	local watchdog = skynet.newservice("watchdog")
	skynet.call(watchdog, "lua", "start", {
		port = 8888,
		maxclient = max_client,
		servername = server_name,
		--nodelay = true,
	})
	print (" watchdog listen on ", 8888)
	skynet.exit()
end)
