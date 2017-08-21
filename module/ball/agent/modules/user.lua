local M = require "module"

local cls = class("user", M)

function cls:ctor(env, dbctx, set, ... )
	-- body
	cls.super.ctor(self, env, dbctx, set)
	self.id   = db.field.new(self, "id", 1, field.data_type.integer, true)
	self.name = db.field.new(self, "name", 2, field.data_type.char)
	self.age  = db.field.new(self, "age", 3, field.data_type.integer)
	self.gold = db.field.new(self, "gold", 4, field.data_type.integer)
	self.diamond = db.field.new(self, "diamond", 5, field.data_type.integer)
end

function cls:set_db(value, ... )
	-- body
	cls.super.set_db(self, value)
end

function cls:login( ... ) 
	cls.super.login(self)
end

function cls:logout( ... )
	-- body
	cls.super.logout(self)
end

function cls:authed( ... )
	-- body
	cls.super.authed(self)
end

function cls:afx( ... )
	-- body
	cls.super.afx(self)
end

function cls:load_cache_to_data( ... )
	-- body
	cls.super.load_cache_to_data(self)
	
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