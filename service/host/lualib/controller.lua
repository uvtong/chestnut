local cls = class("controller")

function cls:ctor(env, ... )
	-- body
	self._env = env
	return self
end

return cls