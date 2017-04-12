local entity = require "db.entity"
local field = require "db.field"
local query = require "query"
local cls = class("checkin", entity)

function cls:ctor(ctx, dbctx, dbset, ... )
	-- body
	cls.super.ctor(self, ctx, dbctx, dbset)
	self.id   = field.new(self, "")
end

return cls