-- local center = require "notification_center"
local socket = require "socket"
local string_pack = string.pack

local cls = class("env")

function cls:ctor( ... )
	-- body
	-- self._center = center.new(self)
	self._fd = false
	return self
end

function cls:set_fd(fd, ... )
	-- body
	self._fd = fd
end

function cls:get_fd( ... )
	-- body
	return self._fd
end

function cls:get_notification_center( ... )
	-- body
	return self._center
end


function cls:post_notification_name(name, object, ... )
	self._center:post_notification_name(name, object, ...)
end

function cls:send_package(pack, ... )
	-- body
	local package = string_pack(">s2", pack)
	socket.write(self._fd, package)
end

return cls