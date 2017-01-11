local skynet = require "skynet"
local dbcontext = require "dbcontext"
local user = require "user"
local context = require "context"

local cls = class("acontext", context)

function cls:ctor( ... )
	-- body
	cls.super.ctor(self, ...)
	
	self._room = false
	self._session = false
	self._dbcontext = dbcontext.new(self)
	self._user = user.new(self, self._dbcontext)
	self._dbcontext:register_user(self._user)
	return self
end

function cls:newborn(gate, uid, subid, secret, suid, ... )
	-- body
	cls.super.newborn(self, gate, uid, subid, secret, suid)
	self._user:set_id(self._uid)
	self._user:set_name("hello")
	self._user:set_age(10)
	self._user:set_gold(1000)
	self._user:set_diamond(10000)
	self._user:insert_db("tg_users")
end

function cls:login(gate, uid, subid, secret, suid)
	assert(uid and subid and secret)
	cls.super.login(self, gate, uid, subid, secret, suid)

end

function cls:logout( ... )
	-- body
	cls.super.logout(self)
end

function cls:set_room(room, ... )
	-- body
	self._room = room
end

function cls:get_room( ... )
	-- body
	return self._room
end

function cls:set_session(session, ... )
	-- body
	self._session = session
end

function cls:get_session( ... )
	-- body
	return self._session
end

return cls