local field = require "db.field"
local entity = require "db.entity"

local cls = class("checkindaily", entity)

function cls:ctor(env, dbctx, set, ... )
	-- body
	cls.super.ctor(self, env, dbctx, set)
	self.uid   = field.new(self, "uid", 2, field.data_type.integer)
	self.month = field.new(self, "month", 3, field.data_type.integer)
	self.count = field.new(self, "count", 4, field.data_type.integer)

	return self
end

function cls:dtor( ... )
	-- body
end

function cls:set_uid(value, ... )
	-- body
	self.uid:set_value(value)
end

function cls:set_month(value, ... )
	-- body
	self.month:set_value(value)
end

function cls:set_count(value, ... )
	-- body
	self.count:set_value(value)
end

return cls