local skynet = require "skynet"
require "skynet.manager"
local log = require "log"

skynet.start(function()
	local logger = skynet.uniqueservice("log")
	skynet.call(logger, "lua", "start")
	
	skynet.newservice("codweb")
	-- skynet.uniqueservice("protoloader")
	
	local console = skynet.newservice("console")
	skynet.newservice("debug_console",8000)
	
	local test = skynet.launch("test", "start");
	local abc = skynet.newservice("abc")

	-- read
	-- local game = skynet.uniqueservice("game")
	-- skynet.name(".game", game)
		
	-- local lb = skynet.newservice("leaderboards", "ara_leaderboards")
	-- skynet.name(".LB", lb)

	log.info("test successful .")
	
	skynet.exit()
end)
