local skynet = require "skynet"
require "skynet.manager"
local sprotoloader = require "sprotoloader"

local max_client = 64

skynet.start(function()
	print("Server start")
	skynet.uniqueservice("protoloader")
	local console = skynet.newservice("console")
	skynet.newservice("debug_console",8000)
	skynet.newservice("simpledb")
	for i=1,5 do
		local db = skynet.newservice("db")
		skynet.name(string.format(".db%d", i), db)
	end
	-- skynet.newservice("testmysql2")
	local watchdog = skynet.newservice("watchdog")
	skynet.call(watchdog, "lua", "start", {
		port = 8888,
		maxclient = max_client,
		nodelay = true,
	})
	print("Watchdog listen on ", 8888)

	skynet.exit()
end)
