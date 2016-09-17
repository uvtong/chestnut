local cls = class("controller")

function cls:ctor(env, name, scene, ... )
	-- body
	self._env = env
	self._name = name
	self._scene = scene
end

function cls:get_name( ... )
	-- body
	return self._name
end

function cls:get_scene( ... )
	-- body
	return self._scene
end

function cls:update(delta, ... )
	-- body
end

function cls:onBack(scene, ... )
	-- body
	self._env:pop()
end

return cls