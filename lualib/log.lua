local skynet = require "skynet"
-- local logger = skynet.uniqueservice("log")
local logger = ".LOG"

local _M = {}

function _M.DEBUG(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
	end
	skynet.send(logger, "lua", "debug", SERVICE_NAME, msg)
end

function _M.INFO(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
	end
	skynet.send(logger, "lua", "info", SERVICE_NAME, msg)
end

function _M.WARN(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
	end
	skynet.send(logger, "lua", "warning", SERVICE_NAME, msg)
end

function _M.ERROR(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
	end
	skynet.send(logger, "lua", "error", SERVICE_NAME, msg)
end

function _M.FATAL(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
	end
	skynet.send(logger, "lua", "fatal", SERVICE_NAME, msg)
end

return _M