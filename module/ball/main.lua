package.cpath = "./../../module/ball/luaclib/?.so;"..package.cpath
local skynet = require "skynet"
require "skynet.manager"
local snax = require "snax"
local log = require "log"

skynet.start(function()
	local logger = skynet.uniqueservice("log")
	skynet.call(logger, "lua", "start")
	
	skynet.uniqueservice("protoloader")
	
	local console = skynet.newservice("console")
	skynet.newservice("debug_console",8000)

	local codweb = skynet.newservice("codweb")
	skynet.call(codweb, "lua", "start")
	
	skynet.launch("battle", "test")
	log.info("ball host successful .")
	
	skynet.exit()
end)
