local skynet = require "context"
local env = require "env"
local cls = class("context", env)

function cls:ctor( ... )
	-- body
	return self
end

return cls