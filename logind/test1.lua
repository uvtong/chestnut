local skynet = require "skynet"
require "skynet.manager"

skynet.start( function () 
	skynet.send(".start_service", "lua", "test", "are you ok.")
	skynet.exit()
end)