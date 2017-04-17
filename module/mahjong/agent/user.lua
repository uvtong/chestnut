local field = require "db.field"
local entity = require "db.entity"
local query = require "query"
local cls = class("user", entity)

function cls:ctor(env, dbctx, set, ... )
	-- body
	cls.super.ctor(self, env, dbctx, set)
	self.uid            = field.new(self, "uid", 1, field.data_type.integer, true)
	self.rcard          = field.new(self, "rcard", 10, field.data_type.integer)
	self.sex            = field.new(self, "sex", 10, field.data_type.integer)
	self.nickname       = field.new(self, "nickname", 10, field.data_type.integer)
	self.province       = field.new(self, "province", 11, field.data_type.integer)
	self.city           = field.new(self, "city", 12, field.data_type.integer)
	self.country        = field.new(self, "country", 13, field.data_type.integer)
	self.headimg        = field.new(self, "headimg", 14, field.data_type.integer)

	assert(self._pk)
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

	self.uid.value     = self._suid
	self.rcard.value   = self._db:get(string.format("tg_users:%d:rcard:", self._suid))
	self.sex           = self._db:get(string.format("tg_users:%d:sex", self._suid))
	self.nickname      = self._db:get(string.format("tg_users:%d:nickname", self._suid))
	self.province      = self._db:get(string.format("tg_users:%d:province", self._suid))
	self.city          = self._db:get(string.format("tg_users:%d:city", self._suid))
	self.country       = self._db:get(string.format("tg_users:%d:country", self._suid))
	self.headimg       = self._db:get(string.format("tg_users:%d:headimg", self._suid))
	
end

function cls:load_db_to_data( ... )
	-- body
	local sql = string.format("select * from tg_users where uid = %d", self._env._suid)
	local res = query.select("tg_users", sql)
	if #res > 0 then
		for k,v in pairs(res[1]) do
			if self[k] then
				self[k].value = v
			end	
		end
	end
end

function cls:update( ... )
	-- body
end

return cls