local skynet = require "skynet"
local debug = debug
local logger = ".LOG"
local string_format = string.format
local skynet_error = skynet.error

local _M = {}

function _M.print( ... )
	-- body
	skynet_error(...)
end

function _M.print_debug(fmt, ... )
	-- body
	local msg = string_format(fmt, ...)
	local debug = string_format("[debug] %s", msg)
	skynet_error(debug)
end

function _M.print_info(fmt, ... )
	-- body
	local msg = string_format(fmt, ...)
	local info = string_format("[info] %s", msg)
	skynet_error(info)
end

function _M.print_warn(fmt, ... )
	-- body
	local msg = string_format(fmt, ...)
	local info = string_format("[warn] %s", msg)
	skynet_error(info)
end

function _M.print_error(fmt, ... )
	-- body
	local msg = string_format(fmt, ...)
	local info = string_format("[error] %s", msg)
	skynet_error(info)
end

function _M.debug(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
	end
	skynet.send(logger, "lua", "debug", SERVICE_NAME, msg)
end

function _M.info(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
	end
	skynet.send(logger, "lua", "info", SERVICE_NAME, msg)
end

function _M.warn(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
	end
	skynet.send(logger, "lua", "warning", SERVICE_NAME, msg)
end

function _M.error(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
	end
	skynet.send(logger, "lua", "error", SERVICE_NAME, msg)
end

function _M.fatal(fmt, ...)
	local msg = string.format(fmt, ...)
	local info = debug.getinfo(2)
	if info then
		msg = string.format("[%s:%d] %s", info.short_src, info.currentline, msg)
	end
	skynet.send(logger, "lua", "fatal", SERVICE_NAME, msg)
end

return _M