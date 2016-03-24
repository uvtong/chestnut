local skynet = require "skynet"
require "skynet.manager"
local sprotoloader = require "sprotoloader"
	
local max_client = 64
	
skynet.start(function()
	print("Server start")
	skynet.uniqueservice("protoloader")
	local console = skynet.newservice("console")
	skynet.newservice("debug_console",8000)
	-- for i=1,5 do
	-- 	local db = skynet.newservice("db")
	-- 	skynet.name(string.format(".db%d", i), db)
	-- end

	skynet.newservice("simpledb")
	local db = skynet.uniqueservice("db")
	skynet.name(".db", db)
	local game = skynet.uniqueservice("game")
   	skynet.newservice("channel")
	skynet.newservice("randomdraw")

	local watchdog = skynet.newservice("watchdog")
	skynet.call(watchdog, "lua", "start", {
		port = 8888,
		maxclient = max_client,
		nodelay = true,
		--emailserver = emailserver
	})
	print("Watchdog listen on ", 8888)

	skynet.send(game, "lua", "start")
	
	skynet.exit()
end)

