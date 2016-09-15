local center = require "notification_center"
local socket = require "socket"
local string_pack = string.pack

local cls = class("env")

function cls:ctor( ... )
	-- body
	self._center = center.new(self)

	self._host = false
	self._send_request = false
	
	self._fd = false
	self._gate = false
	self._version = false
	self._index = false

	return self
end

function cls:set_host(h, ... )
	-- body
	self._host = h
end

function cls:get_host( ... )
	-- body
	return self._host
end

function cls:set_send_request(r, ... )
	-- body
	self._send_request = r
end

function cls:get_send_request( ... )
	-- body
	return self._send_request
end

function cls:set_fd(fd, ... )
	-- body
	self._fd = fd
end

function cls:get_fd( ... )
	-- body
	return self._fd
end

function cls:set_gate(g, ... )
	-- body
	self._gate = g
end

function cls:get_gate( ... )
	-- body
	return self._gate
end

function cls:set_version(v, ... )
	-- body
	self._version = v
end

function cls:get_version( ... )
	-- body
	return self._version
end

function cls:set_index(idx, ... )
	-- body
	self._index = idx
end

function cls:get_index( ... )
	-- body
	return self._index
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