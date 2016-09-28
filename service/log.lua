package.cpath = "../../luaclib/?.so;"..package.cpath
local skynet = require "skynet"
require "skynet.manager"
local logger = require "log.core"
 
local CMD = {}

function CMD.start()
	local log_level = tonumber(skynet.getenv("log_level")) or 0
	local log_rollsize = tonumber(skynet.getenv("log_rollsize")) or 1024
	local log_flushinterval = tonumber(skynet.getenv("log_flushinterval")) or 5
	local root = skynet.getenv "log_root"
	local fd, result = io.open(root)
	if fd == nil then
		os.execute("mkdir " .. root)
	end
	local log_dirname = skynet.getenv("log_dirname") or "test"
	log_dirname = root .. log_dirname
	local log_basename = skynet.getenv("log_basename") or "test"
	logger.init(log_level, log_rollsize, log_flushinterval, log_dirname, log_basename)
end

function CMD.stop( )
	logger.exit()
end

function CMD.debug(name, msg)
	logger.debug(string.format("%s [%s] %s",os.date("%Y-%m-%d %H:%M:%S"), name, msg))
end

function CMD.info(name, msg)
	logger.info(string.format("%s [%s] %s",os.date("%Y-%m-%d %H:%M:%S"), name, msg))
end

function CMD.warning(name, msg)
	logger.warning(string.format("%s [%s] %s",os.date("%Y-%m-%d %H:%M:%S"), name, msg))
end

function CMD.error(name, msg)
	logger.error(string.format("%s [%s] %s",os.date("%Y-%m-%d %H:%M:%S"), name, msg))
end

function CMD.fatal(name, msg)
	logger.fatal(string.format("%s [%s] %s",os.date("%Y-%m-%d %H:%M:%S"), name, msg))
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		if cmd == "start" or cmd == "stop" then
			skynet.retpack(f(...))
		else
			f(...)
		end
	end)

	skynet.register(".LOG")
end)
