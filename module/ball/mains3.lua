package.cpath = "./../../module/ball/luaclib/?.so;"..package.cpath
local skynet = require "skynet"
require "skynet.manager"
local log = require "skynet.log"

skynet.start(function()

	-- base tool
	-- local console = skynet.newservice("console")
	-- skynet.newservice("debug_console",8000)

	local addr = skynet.newservice("codwebs3")
	skynet.call(addr, "lua", "start")
	
	log.info("ball host successful .")
	skynet.exit()
end)
