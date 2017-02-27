local skynet = require "skynet"
local dbcontext = require "dbcontext"
local context = require "context"
local inbox = require "inbox"
local user = require "user"
local log = require "log"
local query = require "query"
local checkindailymgr = require "checkindailymgr"

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
	self._checkindailymgr = checkindailymgr.new(self, self._dbcontext)

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

function cls:newborn(gate, uid, subid, secret, suid, ... )
	-- body
	cls.super.newborn(self, gate, uid, subid, secret, suid)
	
	self._user:set_id(self._suid)
	self._user:set_name("nihao")
	self._user:set_age(10)
	self._user:set_gold(1000)
	self._user:set_diamond(1000)
	self._user:set_checkin_month(0)
	self._user:set_checkin_count(0)
	self._user:set_checkin_mcount(0)
	self._user:set_checkin_lday(0)

	self._user:insert_db("tg_users")
end

function cls:login(gate, uid, subid, secret, suid)
	cls.super.login(self, gate, uid, subid, secret, suid)

	self:load_db_to_data()
	log.info("load_db_to_data over")
end

function cls:logout( ... )
	-- body
	cls.super.logout(self)
end

function cls:load_db_to_data()
	-- load user
	local sql = "select * from tg_users"
	local res = query.select("tg_users", sql)
	if #res > 0 then
		for k,v in pairs(res[1]) do
			if type(v) == "number" then
				assert(self._user[k]:dt() == field.data_type.integer or self._user[k]:dt() == field.data_type.biginteger)
				self._user[k].value = v
			end
		end
	end
end

return cls