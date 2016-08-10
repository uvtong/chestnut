local center = require "notification_center"
local socket = require "socket"

local cls = class("env")

function cls:ctor( ... )
	-- body
	self._center = center.new(self)
	return self
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
	local package = string.pack(">s2", pack)
	socket.write(self._client_fd, package)
end

return cls