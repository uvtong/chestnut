local s = [[
local dbcontext = require "dbcontext"
local cls = class("%s", dbcontext)

function cls:ctor(env, ... )
	-- body
	cls.super.ctor(self, env)
	return self
end

%s

return cls
]]

return s