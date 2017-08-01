local skynet = require "skynet"
require "skynet.manager"
local log = require "skynet.log"

skynet.start(function()
	
	skynet.uniqueservice("protoloader")
	
	-- local console = skynet.newservice("console")
	-- skynet.newservice("debug_console",8000)

	local codweb = skynet.uniqueservice("codweb")
	skynet.call(codweb, "lua", "start")
	
	log.info("host successful .")
	skynet.exit()
end)
