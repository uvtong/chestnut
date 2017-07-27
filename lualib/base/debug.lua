local log = require "skynet.log"

function debug.msgh( ... )
	-- body
	log.info(tostring(...))
	log.info(debug.traceback())
end