local cls = class("component")

function cls:ctor(env, entity, name, ... )
	-- body
	assert(env and entity and name)
	self._env    = env
	self._entity = entity
	self._name   = name
	self._entity._components[name] = self
	return self
end

return cls