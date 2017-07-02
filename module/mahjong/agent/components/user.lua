local field = require "db.field"
local entity = require "db.entity"
local query = require "query"
local errorcode = require "errorcode"
local component = require "component"

local cls = class("user", component)

function cls:ctor(env, entity, name, ... )
	-- body
	cls.super.ctor(self, env, entity, name)

	self._tname = "tb_user"
	self._mk    = {}

end

function cls:set_uid(value, ... )
	-- body
	self.uid:set_value(value)
end

function cls:set_nameid(value, ... )
	-- body
	self.name:set_value(value)
end

function cls:set_age(value, ... )
	-- body
	self.age:set_value(value)
end

function cls:set_gold(value, ... )
	-- body
	self.gold:set_value(value)
end

function cls:set_diamond(value, ... )
	-- body
	self.diamond:set_value(value)
end

function cls:set_checkin_month(value, ... )
	-- body
	self.checkin_month:set_value(value)
end

function cls:set_checkin_count(value, ... )
	-- body
	self.checkin_count:set_value(value)
end

function cls:set_checkin_mcount(value, ... )
	-- body
	self.checkin_mcount:set_value(value)
end

function cls:set_checkin_lday(value, ... )
	-- body
	self.checkin_lday:set_value(value)
end

function cls:set_rcard(value, ... )
	-- body
	self.rcard:set_value(value)
end

function cls:set_name(value, ... )
	-- body
	self.name = value
end

function cls:load_cache_to_data( ... )
	-- body

	local r = {}
	local uid           = self._env._uid

	assert(uid)
	r.rcard             = math.tointeger(self._env._db:get(string.format("tg_user:%d:rcard", self._env._uid)))
	r.sex               = math.tointeger(self._env._db:get(string.format("tg_user:%d:sex", self._env._uid)))
	r.nickname          = self._env._db:get(string.format("tg_user:%d:nickname", self._env._uid))
	r.province          = self._env._db:get(string.format("tg_user:%d:province", self._env._uid))
	r.city              = self._env._db:get(string.format("tg_user:%d:city", self._env._uid))
	r.country           = self._env._db:get(string.format("tg_user:%d:country", self._env._uid))
	r.headimg           = self._env._db:get(string.format("tg_user:%d:headimg", self._env._uid))

	self._mk[uid] = r
end

function cls:first( ... )
	-- body
	local uid = self._entity:get_uid()
	local r = self._mk[uid]

	local res = {}
	res.errorcode = errorcode.SUCCESS
	res.name   = r.nickname
	res.nameid = self._env._nickname_uid
	res.rcard  = r.rcard
	res.sex    = r.sex

	return res
end

return cls