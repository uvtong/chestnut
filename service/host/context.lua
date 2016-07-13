local socket = require "socket"
local cls = class("context")

function cls:ctor( ... )
	-- body
	self._client_fd = 0
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

function cls:set_client_fd(fd, ... )
	-- body
	self._client_fd = fd
end

function cls:get_client_fd( ... )
	-- body
	return self._client_fd
end

function cls:send_package(pack, ... )
	-- body
	local package = string.pack(">s2", pack)
	socket.write(self._client_fd, package)
end

function cls:logout( ... )
	-- body
	if gate then
		skynet.call(gate, "lua", "logout", userid, subid)
	end
	skynet.exit()
end

return cls