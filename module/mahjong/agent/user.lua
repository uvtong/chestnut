local field = require "db.field"
local entity = require "db.entity"
local query = require "query"
local cls = class("user", entity)

function cls:ctor(env, dbctx, set, ... )
	-- body
	cls.super.ctor(self, env, dbctx, set)
	self.uid   = field.new(self, "uid", 1, field.data_type.integer, true)
	self.name = field.new(self, "name", 2, field.data_type.char)
	self.age  = field.new(self, "age", 3, field.data_type.integer)
	self.gold = field.new(self, "gold", 4, field.data_type.integer)
	self.diamond = field.new(self, "diamond", 5, field.data_type.integer)
	self.checkin_month = field.new(self, "checkin_month", 6, field.data_type.integer)
	self.checkin_count = field.new(self, "checkin_count", 7, field.data_type.integer)
	self.checkin_mcount = field.new(self, "checkin_mcount", 8, field.data_type.integer)
	self.checkin_lday = field.new(self, "checkin_lday", 9, field.data_type.integer)

	self.uid.value = self._env._suid
	assert(self._pk)
end

function cls:set_uid(value, ... )
	-- body
	self.uid:set_value(value)
end

function cls:set_name(value, ... )
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

function cls:load_cache_to_data( ... )
	-- body
	self.uid.value = assert(self._env._suid)
	local res = query.hget(self.id.value)
	if res == nil then
		skynet.call("WATCHER", "lua", "query", "load", self.id.value)
	end
	local res = query.hget(self.id.value)
	self.name.value    = res.name
	self.age.value     = res.age
	self.gold.value    = res.gold
	self.diamond.value = res.diamond
	self.checkin_month.value  = res.checkin_month
	self.checkin_count.value  = res.checkin_count
	self.checkin_mcount.value = res.checkin_mcount
	self.checkin_lday.value   = res.checkin_lday
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
	if #self._changed > 0 then
		skynet.send("WATCHER", "lua", "update", self._changed)
	end
end

return cls