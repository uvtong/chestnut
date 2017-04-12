local assert = assert
local cls = class("controller")

function cls:ctor(env, name, ... )
	-- body
	assert(env and name)
	self._env = env
	self._name = name
end

function cls:get_name( ... )
	-- body
	return self._name
end

return cls