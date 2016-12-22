local db = require "db"
local cls = class("user", db.entity)

function cls:ctor( ... )
	-- body
	self.id   = db.field(self, "id", 1, cls.data_type.integer, true)
	self.name = db.field(self, "name", 2, cls.data_type.char)
	self.age  = db.field(self, "age", 3, cls.data_type.integer)
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

return cls