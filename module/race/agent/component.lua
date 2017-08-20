local cls = class("component")

function cls:ctor(e, name, ... )
	-- body
	assert(e and name)
	self._env    = e._env
	self._entity = e
	self._name   = name
	self._entity._components[name] = self
	return self
end

return cls