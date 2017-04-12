local cls = class("notification")

function cls:ctor(env, ... )
	-- body
	self._env = env
	return self
end

function cls:set_func(func, ... )
	-- body
	self._func = func
end

function cls:get_func( ... )
	-- body
	return self._func
end

function cls:set_name(name, ... )
	-- body
	self._name = name
end

function cls:get_name( ... )
	-- body
	return self._name
end

function cls:set_object(object, ... )
	-- body
	self._object = object
end

function cls:get_object( ... )
	-- body
	return self._object
end

return cls