local skynet = require "skynet"
local dbcontext = require "dbcontext"
local context = require "context"
local inbox = require "inbox"
local user = require "user"
local call = skynet.call
local assert = assert

local state = {}
state.NONE         = 0
state.NORMAL       = 1
state.ENTER_ROOM   = 2
state.ENTER_ROOMED = 3


local cls = class("acontext", context)

context.state = state

function cls:ctor( ... )
	-- body
	cls.super.ctor(self, ...)
	
	self._dbcontext = dbcontext.new()

	self._gate = false
	self._uid = false
	self._subid = false
	self._secret = false
	self._room = nil
	self._state = state.NONE
	self._last_state = state.NONE

	self._user = nil
	self._inbox = inbox.new()
	return self
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

function cls:get_state( ... )
	-- body
	return self._state
end

function cls:set_state(value, ... )
	-- body
	self._state = value
end

function cls:get_last_state( ... )
	-- body
	return self._last_state
end

function cls:set_last_state(value, ... )
	-- body
	self._last_state = value
end

function cls:new_user(gate, uid, subid, secret, ... )
	-- body
	self._gate = gate
	self._uid = uid
	self._subid = subid
	self._secret = secret

	self._user = user.new(uid)
end

function cls:login(gate, uid, subid, secret)
	assert(uid and subid and secret)
	self._gate = gate
	self._uid = uid
	self._subid = subid
	self._secret = secret
	-- self._host_udbcontext:load_db_to_data()
	self._join = false

	-- self._inbox:
	return self._uid
end

function cls:logout( ... )
	-- body
	if self._gate then
		skynet.call(self._gate, "lua", "logout", self._uid, self._subid)
	end
	skynet.call(".AGENT_MGR", "lua", "exit")
	-- skynet.exit()
end

return cls