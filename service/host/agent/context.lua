local env = require "env"
local assert = assert

local cls = class("context", env)

function cls:ctor( ... )
	-- body
	cls.super.ctor(self)
	self._host = false
	self._send_request = false
	self._fd = false
	self._gate = false
	self._version = false
	self._index = false
	self._uid = false
	self._subid = false
	self._secret = false
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

function cls:set_index(idx, ... )
	-- body
	self._index = idx
end

function cls:send_client(tag, args, ... )
	-- body
	assert(self._send_request)
	local pack = self._send_request(tag, args)
	cls.super.send_package(pack)
end

function cls:login(uid, subid, secret)
	assert(uid and subid and secret)
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

function cls:get_subid( ... )
	-- body
	return self._subid
end

function cls:get_secret( ... )
	-- body
	return self._secret
end

return cls