local field = require "db.field"
local entity = require "db.entity"
local cls = class("user", entity)

function cls:ctor(env, dbctx, set, ... )
	-- body
	cls.super.ctor(self, env, dbctx, set)
	self.id   = field.new(self, "id", 1, field.data_type.integer, true)
	self.name = field.new(self, "name", 2, field.data_type.char)
	self.age  = field.new(self, "age", 3, field.data_type.integer)
	self.gold = field.new(self, "gold", 4, field.data_type.integer)
	self.diamond = field.new(self, "diamond", 5, field.data_type.integer)
	self.checkin_month = field.new(self, "checkin_month", 6, field.data_type.integer)
	self.checkin_count = field.new(self, "checkin_count", 7, field.data_type.integer)
	self.checkin_mcount = field.new(self, "checkin_mcount", 8, field.data_type.integer)
	self.checkin_lday = field.new(self, "checkin_lday", 9, field.data_type.integer)
	assert(self._pk)
end

function cls:set_id(value, ... )
	-- body
	self.id:set_value(value)
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

return cls