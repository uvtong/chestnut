local skynet = require "skynet"
require "skynet.manager"
local log = require "skynet.log"
local util = require "util"

skynet.start(function()
	-- local logger = skynet.uniqueservice("log")
	-- skynet.call(logger, "lua", "start")
	
	-- skynet.uniqueservice("protoloader")
	
	local console = skynet.newservice("console")
	skynet.newservice("debug_console",8000)
	
	local c1 = util.set_timeout(1 * 100, function ( ... )
		-- body
		print(1)
	end)

	local c2 = util.set_timeout(3 * 100, function ( ... )
		-- body
		print(2)
	end)


	local c3 = util.set_timeout(4 * 100, function ( ... )
		-- body
		print(3)
	end)

	c2()
	
	-- local test = skynet.launch("test", "start");
	-- local abc = skynet.newservice("abc")

	-- read
	-- local game = skynet.uniqueservice("game")
	-- skynet.name(".game", game)
		
	-- local lb = skynet.newservice("leaderboards", "ara_leaderboards")
	-- skynet.name(".LB", lb)

	-- log.info("test successful .")
	
	-- skynet.exit()
end)
