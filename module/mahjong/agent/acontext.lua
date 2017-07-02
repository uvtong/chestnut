local skynet = require "skynet"
local context = require "context"
local inbox = require "inbox"
local log = require "log"
local errorcode = require "errorcode"
local radiocenter = require "radiocenter"
local entity = require "entity"

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
	self._db = nil
	self._nickname_uid = nil
	self._room = nil
	
	self._entity = entity.new(self, self._uid)
	return self
end

function cls:get_db( ... )
	-- body
	return self._db
end

function cls:set_db(value, ... )
	-- body
	self._db = value
end

function cls:get_nickname_uid( ... )
	-- body
	return self._nickname_uid
end

function cls:set_room(room, ... )
	-- body
	self._room = room
end

function cls:get_room( ... )
	-- body
	return self._room
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

function cls:login(gate, uid, subid, secret)

	cls.super.login(self, gate, uid, subid, secret)

	self._entity:set_uid(uid)
	
	self:load_cache_to_data()
	log.info("load_cache_to_data over")

	local entity = self:get_entity()
	local sysinbox = entity:get_component("sysinbox")
	sysinbox:poll()
end

function cls:logout( ... )
	-- body
	cls.super.logout(self)
end

function cls:afk( ... )
	-- body
end

function cls:load_cache_to_data()
	-- load user
	self._entity:load_cache_to_data()
end

function cls:get_entity( ... )
	-- body
	return self._entity
end

return cls