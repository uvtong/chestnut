local buff = require "room.buff"
local cls = class("buff")

function cls:ctor(ctx, id, type, limit, ... )
	-- body
	cls.super.ctor(self, ctx, id, type, limit)
end

return cls