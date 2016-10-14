local math3d = require "math3d"
local float = require "float"
local assert = assert
local cls = class("ball")

function cls:ctor(agent, session, radis, length, width, height, pos, dir, vel, ... )
	-- body
	assert(agent and session)
	self._agent = agent
	self._session = session
	self._uid = 0

	-- data
	self._radis = radis
	self._length = length
	self._width = width
	self._height = height
	self._position = pos
	self._direction = dir
	self._vel = vel
	
	self:cal_aabb()
end

function cls:cal_aabb( ... )
	-- body
	local x, y, z = self._position:unpack()
	local nx = x - (self._length / 2)
	local ny = y - (self._width / 2)
	local nz = z - (self._height / 2)
	local xx = x + (self._length / 2)
	local xy = y + (self._width / 2)
	local xz = z + (self._height / 2)
	local min = math3d.vector3(nx, ny, nz)
	local max = math3d.vector3(xx, xy, xz)
	self._aabb = math3d.aabb(min, max)
end

function cls:set_uid(uid, ... )
	-- body
	self._uid = uid
end

function cls:get_uid( ... )
	-- body
	return self._uid
end

function cls:get_session( ... )
	-- body
	return self._session
end

function cls:get_radis( ... )
	-- body
	return self._radis
end

function cls:get_length( ... )
	-- body
	return self._length
end

function cls:get_width( ... )
	-- body
	return self._width
end

function cls:get_height( ... )
	-- body
	return self._height
end

function cls:get_aabb( ... )
	-- body
	return self._aabb
end

function cls:move_by(vec3, ... )
	-- body
	local x1, y1, z1 = self._position:unpack()
	local x2, y2, z2 = vec3:unpack()
	local x = x1 + x2
	local y = y1 + y2
	local z = z1 + z2
	self._position:pack(x, y, z)
end

function cls:move_to(vec3, ... )
	-- body
	self._position:copy(vec3)
end

function cls:set_direction(vec3, ... )
	-- body
	self._direction:copy(vec3)
end

function cls:pack_position( ... )
	-- body
	local x, y, z = self._position:unpack()
	local res = string.pack("<fff", x, y, z)
	return res
end

function cls:pack_sproto_px( ... )
	-- body
	local x, y, z = self._position:unpack()
	return float.encode(x)
end

function cls:pack_sproto_py( ... )
	-- body
	local x, y, z = self._position:unpack()
	return float.encode(y)
end

function cls:pack_sproto_pz( ... )
	-- body
	local x, y, z = self._position:unpack()
	return float.encode(z)
end

function cls:pack_direction( ... )
	-- body
	local x, y, z = self._direction:unpack()
	local res = string.pack("<fff", x, y, z)
	return res
end

function cls:pack_sproto_dx( ... )
	-- body
	local x, y, z = self._direction:unpack()
	return float.encode(x)
end

function cls:pack_sproto_dy( ... )
	-- body
	local x, y, z = self._direction:unpack()
	return float.encode(y)
end

function cls:pack_sproto_dz( ... )
	-- body
	local x, y, z = self._direction:unpack()
	return float.encode(z)
end

function cls:pack_vel( ... )
	-- body
	local res = string.pack("<f", self._vel)
	return res
end

function cls:pack_sproto_vel( ... )
	-- body
	return float.encode(self._vel)
end

function cls:sync_position(buffer, ... )
	-- body
	local x, y, z = string.unpack("<fff", buffer)
	self._position:pack(x, y, z)
end

function cls:sync_direction(buffer, ... )
	-- body
	local x, y, z = string.unpack("<fff", buffer)
	self._direction:pack(x, y, z)
end

return cls
