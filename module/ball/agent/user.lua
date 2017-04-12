local field = require "db.field"
local db = require "db"
local cls = class("user", db.entity)

function cls:ctor(env, dbctx, set, ... )
	-- body
	cls.super.ctor(self, env, dbctx, set)
	self.id   = db.field.new(self, "id", 1, field.data_type.integer, true)
	self.name = db.field.new(self, "name", 2, field.data_type.char)
	self.age  = db.field.new(self, "age", 3, field.data_type.integer)
	self.gold = db.field.new(self, "gold", 4, field.data_type.integer)
	self.diamond = db.field.new(self, "diamond", 5, field.data_type.integer)
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

return cls