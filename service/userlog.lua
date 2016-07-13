package.path = "./../../lualib/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local log = require "log"

skynet.register_protocol {
	name = "text",
	id = skynet.PTYPE_TEXT,
	unpack = skynet.tostring,
	dispatch = function(_, address, msg)
		-- print(string.format("[:%08x][%.2f]: %s", address, skynet.time(), msg))
		-- print(string.format("[:%08x][%s]: %s", address, os.date(), msg))
		log.INFO(string.format("[:%08x][%s]: %s", address, os.date(), msg))
	end
}

skynet.register_protocol {
	name = "SYSTEM",
	id = skynet.PTYPE_SYSTEM,
	unpack = function(...) return ... end,
	dispatch = function()
		-- reopen signal
		-- print("SIGHUP")
		log.INFO("SIGHUP")
	end
}

skynet.start(function()
	skynet.register ".logger"
end)