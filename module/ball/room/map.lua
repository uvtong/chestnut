local math3d = require "math3d"
local cls = class("map")

function cls:ctor( ... )
	-- body
	local min = math3d.vector3(0, 0, 0)
	local max = math3d.vector3(100, 100, 0)
	self._aabb = math3d.aabb(min, max)
end

function cls:get_aabb( ... )
	-- body
	return self._aabb
end

return cls