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
	
	self._gate = false
	self._uid = false
	self._subid = false
	self._secret = false
	self._room = nil
	self._host_udbcontext = host_udbcontext.new(self, rdb, wdb)
	return self
end

function cls:login(gate, uid, subid, secret)
	assert(uid and subid and secret)
	assert(self._uid == false)
	self._gate = gate
	self._uid = uid
	self._subid = subid
	self._secret = secret
	self._host_udbcontext:load_db_to_data()
	return self._uid
end

function cls:logout( ... )
	-- body
	if self._gate then
		skynet.call(self._gate, "lua", "logout", self._uid, self._subid)
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

function cls:set_room(room, ... )
	-- body
	self._room = room
end

function cls:get_room( ... )
	-- body
	return self._room
end

function cls:get_host_udbcontext( ... )
	-- body
	return self._host_udbcontext
end

return cls