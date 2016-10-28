local math3d = require "math3d"
local cls = class("map")

function cls:ctor(scene, ... )
	-- body
	assert(scene)
	self._scene = scene

	local min = math3d.vector3(0, 0, 0)
	local max = math3d.vector3(100, 0, 100)
	self._aabb = math3d.aabb(min, max)
	self._min = min
	self._max = max
end

function cls:get_aabb( ... )
	-- body
	return self._aabb
end

function cls:min( ... )
	-- body
	return self._min
end

function cls:max( ... )
	-- body
	return self._max
end

return cls