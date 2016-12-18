local skynet = require "skynet"
require "skynet.manager"
local log = require "log"

skynet.start(function()
	local logger = skynet.uniqueservice("log")
	skynet.call(logger, "lua", "start")
	
	skynet.uniqueservice("protoloader")
	local console = skynet.newservice("console")
	skynet.newservice("debug_console",8000)

	local codweb = skynet.uniqueservice("codweb")
	skynet.call(codweb, "lua", "start")
	
	log.info("host successful .")
	skynet.exit()
end)
