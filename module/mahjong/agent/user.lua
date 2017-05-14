local field = require "db.field"
local entity = require "db.entity"
local query = require "query"
local cls = class("user", entity)

function cls:ctor(env, dbctx, set, ... )
	-- body
	cls.super.ctor(self, env, dbctx, set)
	self.uid            = field.new(self, "uid", 1, field.data_type.integer, true)
	self.rcard          = field.new(self, "rcard", 7, field.data_type.integer)
	self.sex            = field.new(self, "sex", 8, field.data_type.integer)
	self.nickname       = field.new(self, "nickname", 9, field.data_type.integer)
	self.province       = field.new(self, "province", 10, field.data_type.integer)
	self.city           = field.new(self, "city", 11, field.data_type.integer)
	self.country        = field.new(self, "country", 12, field.data_type.integer)
	self.headimg        = field.new(self, "headimg", 13, field.data_type.integer)

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

	self.uid.value      = self._env._suid
	self.rcard.value    = math.tointeger(self._env._db:get(string.format("tg_user:%d:rcard", self._env._uid)))
	self.sex.value      = math.tointeger(self._env._db:get(string.format("tg_user:%d:sex", self._env._uid)))
	self.nickname.value = self._env._db:get(string.format("tg_user:%d:nickname", self._env._uid))
	self.province.value = self._env._db:get(string.format("tg_user:%d:province", self._env._uid))
	self.city.value     = self._env._db:get(string.format("tg_user:%d:city", self._env._uid))
	self.country.value  = self._env._db:get(string.format("tg_user:%d:country", self._env._uid))
	self.headimg.value  = self._env._db:get(string.format("tg_user:%d:headimg", self._env._uid))

	-- self:print_info()
end

function cls:update( ... )
	-- body
end

return cls