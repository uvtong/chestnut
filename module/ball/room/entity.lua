local cls = class("entity")

function cls:ctor( ... )
	-- body
	self._idx = idx
	self._components = {}
end

function cls:get_idx( ... )
	-- body
	return _idx
end

function cls:get_component(name, ... )
	-- body
	assert(name)
	return self._components[name]
end

function cls:add_component(name, o, ... )
	-- body
	self._components[name] = o
	o:set_entity(self)
end

return cls