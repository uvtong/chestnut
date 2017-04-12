local cls = class("view")

function cls:ctor(scene, ... )
	-- body
	assert(scene)
	self._scene = scene

	self._aabb = nil
end

function cls:get_aabb( ... )
	-- body
	return self._aabb
end

function cls:translate( ... )
	-- body
end

return cls