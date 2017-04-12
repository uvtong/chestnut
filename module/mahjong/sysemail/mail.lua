local field = require "db.field"
local entity = require "db.entity"
local query = require "query"
local cls = class("mail", entity)

function cls:ctor(env, dbctx, set, ... )
	-- body
	cls.super.ctor(self, env, dbctx, set)
	self.id        = field.new(self, "id", 1, field.data_type.integer, true)
	self.datetime  = field.new(self, "datetime", 2, field.data_type.integer)
	self.title     = field.new(self, "title", 3, field.data_type.char)
	self.content   = field.new(self, "content", 4, field.data_type.char)
	return self
end

function cls:set_id(value, ... )
	-- body
	self.id:set_value(value)
end

function cls:set_datetime(value, ... )
	-- body
	self.datetime:set_value(value)
end

function cls:set_title(value, ... )
	-- body
	self.title:set_value(value)
end

function cls:set_content(value, ... )
	-- body
	self.content:set_value(value)
end

return cls