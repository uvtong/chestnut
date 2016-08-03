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

function cls:set_send_request(r, ... )
	-- body
	self._send_request = r
end

function cls:set_fd(fd, ... )
	-- body
	self._fd = fd
end

function cls:set_gate(g, ... )
	-- body
	self._gate = g
end

function cls:set_version(v, ... )
	-- body
	self._version = v
end

function cls:set_index(idx, ... )
	-- body
	self._index = idx
end

function cls:send_package(pack, ... )
	-- body
	local package = string.pack(">s2", pack)
	socket.write(self._client_fd, package)
end

function cls:login(uid, subid, secret)
	self._uid = uid
	self._subid = subid
	self._secret = secret
end

function cls:logout( ... )
	-- body
	if gate then
		skynet.call(gate, "lua", "logout", userid, subid)
	end
	skynet.exit()
end

function cls:get_uid( ... )
	-- body
	return self._uid
end

return cls