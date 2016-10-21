local math3d = require "math3d"
local float = require "float"
local assert = assert
local cls = class("ball")

function cls:ctor(id, scene, agent, session, radis, length, width, height, pos, dir, vel, ... )
	-- body
	assert(id and scene and agent and session)
	self._scene = scene
	self._agent = agent
	self._session = session
	self._uid = 0
	self._idx = 0
	self._id = id
	self._player = nil

	-- data
	self._radis = radis
	self._length = length
	self._width = width
	self._height = height
	
	self._pos = pos
	self._dir = dir
	self._vel = vel

	self:cal_aabb()
end

function cls:cal_aabb( ... )
	-- body
	local x, y, z = self._pos:unpack()
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

function cls:get_id( ... )
	-- body
	return self._id
end

function cls:get_uid( ... )
	-- body
	return self._uid
end

function cls:set_uid(uid, ... )
	-- body
	self._uid = uid
end

function cls:get_session( ... )
	-- body
	return self._session
end

function cls:set_session(value, ... )
	-- body
	self._session = value
end

function cls:set_idx(idx, ... )
	-- body
	self._idx = idx
end

function cls:get_idx( ... )
	-- body
	return self._idx
end

function cls:set_player(player, ... )
	-- body
	self._player = player
end

function cls:get_player( ... )
	-- body
	return self._player
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

function cls:get_dir( ... )
	-- body
	return self._dir
end

function cls:set_dir(copy, ... )
	-- body
	self._dir:copy(copy)
end

function cls:get_vel( ... )
	-- body
	return self._vel
end

function cls:set_vel(value, ... )
	-- body
	self._vel = value
end

function cls:get_pos( ... )
	-- body
	return self._pos
end

function cls:get_aabb( ... )
	-- body
	return self._aabb
end

function cls:move_by(vec3, ... )
	-- body
	local x1, y1, z1 = self._pos:unpack()
	local x2, y2, z2 = vec3:unpack()
	local x = x1 + x2
	local y = y1 + y2
	local z = z1 + z2
	self._pos:pack(x, y, z)
end

function cls:move_by(x2, y2, z2, ... )
	-- body
	local x1, y1, z1 = self._pos:unpack()
	local x = x1 + x2
	local y = y1 + y2
	local z = z1 + z2
	self._pos:pack(x, y, z)
end

function cls:move_to(vec3, ... )
	-- body
	self._pos:copy(vec3)
end

function cls:pack_pos( ... )
	-- body
	local x, y, z = self._pos:unpack()
	local res = string.pack("<fff", x, y, z)
	return res
end

function cls:pack_sproto_px( ... )
	-- body
	local x, y, z = self._pos:unpack()
	return float.encode(x)
end

function cls:pack_sproto_py( ... )
	-- body
	local x, y, z = self._pos:unpack()
	return float.encode(y)
end

function cls:pack_sproto_pz( ... )
	-- body
	local x, y, z = self._pos:unpack()
	return float.encode(z)
end

function cls:pack_dir( ... )
	-- body
	local x, y, z = self._dir:unpack()
	local res = string.pack("<fff", x, y, z)
	return res
end

function cls:pack_sproto_dx( ... )
	-- body
	local x, y, z = self._dir:unpack()
	return float.encode(x)
end

function cls:pack_sproto_dy( ... )
	-- body
	local x, y, z = self._dir:unpack()
	return float.encode(y)
end

function cls:pack_sproto_dz( ... )
	-- body
	local x, y, z = self._dir:unpack()
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

return cls
