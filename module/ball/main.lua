package.cpath = "./../../module/ball/luaclib/?.so;"..package.cpath
local skynet = require "skynet"
require "skynet.manager"
local snax = require "skynet.snax"
local log = require "skynet.log"

skynet.start(function()
	
	skynet.uniqueservice("protoloader")
	
	-- local console = skynet.newservice("console")
	-- skynet.newservice("debug_console",8000)

	local codweb = skynet.newservice("codweb")
	skynet.call(codweb, "lua", "start")
	
	-- skynet.launch("battle", "test")
	log.info("ball host successful .")
	
	skynet.exit()
end)
