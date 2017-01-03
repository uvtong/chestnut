local skynet = require "skynet"
local dbcontext = require "dbcontext"
local context = require "context"
local inbox = require "inbox"
local user = require "user"
local log = require "log"
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
	
	
	self._room = nil
	self._state = state.NONE
	self._last_state = state.NONE

	self._dbcontext = dbcontext.new(self)

	self._user = user.new(self, self._dbcontext, nil)
	self._inbox = inbox.new(self, self._dbcontext, nil)

	self._dbcontext:register_user(self._user)
	self._dbcontext:register_set(self._inbox)
	return self
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

function cls:newborn(gate, uid, subid, secret, ... )
	-- body
	cls.super.newborn(self, gate, uid, subid, secret)
	
	self._user:set_id(self._uid)
	log.info(self._user.id.name)
	self._user:set_name("nihao")
	self._user:set_age(10)
	self._user:set_gold(1000)
	self._user:set_diamond(1000)

	self._user:insert_db("tg_users")
end

function cls:login(gate, uid, subid, secret)
	cls.super.login(self, gate, uid, subid, secret)

	self._join = false
	
	self._dbcontext:load_db_to_data()
	log.info("load_db_to_data over")
end

function cls:logout( ... )
	-- body
	cls.super.logout(self)

end

return cls