local dbcontext = require "dbcontext"
local cls = class("gdbcontext", dbcontext)

function cls:ctor(env, rdb, wdb, ... )
	-- body
	cls.super.ctor(self, env, rdb, wdb)
	return self
end

return self