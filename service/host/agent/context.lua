local skynet = require "skynet"
local host_udbcontext = require "host_udbcontext"
local env = require "env"
local call = skynet.call
local assert = assert
local rdb = ".DB"
local wdb = ".DB"

local cls = class("context", env)

function cls:ctor( ... )
	-- body
	cls.super.ctor(self, ...)
	self._host = false
	self._send_request = false

	-- uid
	self._uid = false
	self._subid = false
	self._secret = false
	self._host_udbcontext = host_udbcontext.new(self, rdb, wdb)
	self._controllers = {}
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

function cls:login(uid, subid, secret)
	assert(uid and subid and secret)
	self._uid = uid
	self._subid = subid
	self._secret = secret
	self._host_udbcontext:load_db_to_data()
	return self._uid
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