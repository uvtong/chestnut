local skynet = require "skynet"
local socket = require "skynet.socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local center = require "notification_center"
local log = require "log"
local string_pack = string.pack
local max = 2 ^ 16 - 1

local cls = class("context")

function cls:ctor( ... )
	-- body
	self._center = center.new(self)

	local host = sprotoloader.load(1):host "package"
	local send_request = host:attach(sprotoloader.load(2))

	self._host = host
	self._send_request = send_request
	self._response_session = 0
	self._response_session_name = {}
	
	self._fd = false
	self._version = false
	self._index = false

	self._gate   = nil
	self._uid    = nil
	self._subid  = nil
	self._secret = nil

	return self
end

function cls:get_host( ... )
	-- body
	return self._host
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

function cls:send_request(name, args, ... )
	-- body
	assert(name and args)
	
	self:send_request_id(self._fd, name, args)
end

function cls:send_package_id(id, pack, ... )
	-- body
	local package = string_pack(">s2", pack)
	socket.write(id, package)
end

function cls:send_request_id(id, name, args, ... )
	-- body
	assert(name and args)
	
	self._response_session = self._response_session + 1 % max
	self._response_session_name[self._response_session] = name
	local request = self._send_request(name, args, self._response_session)
	self:send_package_id(id, request)
end

function cls:get_name_by_session(session, ... )
	-- body
	return self._response_session_name[session]
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

function cls:get_suid( ... )
	-- body
	return self._suid
end

function cls:login(gate, uid, subid, secret)
	assert(gate and uid and subid and secret)
	self._gate = gate
	self._uid = uid
	self._subid = subid
	self._secret = secret
end

function cls:logout( ... )
	-- body
	if self._gate then
		log.info("call gate logout")
		skynet.call(self._gate, "lua", "logout", self._uid, self._subid)
	end
	skynet.call(".AGENT_MGR", "lua", "exit", self._uid)
	-- skynet.exit()
end

return cls