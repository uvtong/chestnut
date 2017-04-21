local skynet = require "skynet"
local dbcontext = require "dbcontext"
local context = require "context"
local inbox = require "inbox"
local user = require "user"
local log = require "log"
local checkindailymgr = require "checkindailymgr"
local errorcode = require "errorcode"
local radiocenter = require "radiocenter"
local sysinbox = require "sysinbox"
local recordmgr = require "recordmgr"

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
	self._state = state.NONE
	self._last_state = state.NONE

	self._dbcontext = dbcontext.new(self)

	self._user = user.new(self, self._dbcontext, nil)
	self._inbox = inbox.new(self, self._dbcontext, nil)
	self._checkindailymgr = checkindailymgr.new(self, self._dbcontext)
	self._sysinbox = sysinbox.new(self, self._dbcontext)
	self._recordmgr = recordmgr.new(self, self._dbcontext)

	self._cancelupdate = nil

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

function cls:login(gate, uid, subid, secret)
	cls.super.login(self, gate, uid, subid, secret)

	self:load_cache_to_data()
	log.info("load_cache_to_data over")

	self._sysinbox:poll()
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
	self._suid = math.tointeger(self._db:get(string.format("tg_uid:%s:suid", self._uid)))
	self._nickname_uid = math.tointeger(self._db:get(string.format("tg_uid:%s:nickname_uid", self._uid)))
	self._user:load_cache_to_data()
	self._sysinbox:load_cache_to_data()
	self._recordmgr:load_cache_to_data()
end

function cls:first( ... )
	-- body
	local res = {}
	res.errorcode = errorcode.SUCCESS
	res.name   = self._user.nickname.value
	res.nameid = self._nickname_uid
	res.rcard  = self._user.rcard.value
	res.board  = radiocenter.board()
	res.adver  = radiocenter.adver()
	res.sex    = self._user.sex.value

	return res
end

return cls