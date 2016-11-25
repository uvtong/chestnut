local skynet = require "skynet"
local cls = class("car")

function cls:ctor(id, uid, ... )
	-- body
	self._id = id
	self._uid = uid
	self._buff = nil
	self._hp = 0
	self._x = 0
	self._y = 0
	self._z = 0
	return self
end

function cls:get_id( ... )
	-- body
	return self._id
end

function cls:set_buff(value, ... )
	-- body
	self._buff = value
end

function cls:get_buff( ... )
	-- body
	return self._buff
end

function cls:get_player( ... )
	-- body
	return self._player
end

function cls:set_player(value, ... )
	-- body
	self._player = value
end

function cls:get_hp( ... )
	-- body
	return self._hp
end

function cls:set_hp(value, ... )
	-- body
	self._hp = value
end

function cls:get_x( ... )
	-- body
	return self._x
end

function cls:set_x(value, ... )
	-- body
	self._x = value
end

function cls:get_y( ... )
	-- body
	return self._y
end

function cls:set_y(value, ... )
	-- body
	self._y = value
end

function cls:get_z( ... )
	-- body
	return self._z
end

function cls:set_z(value, ... )
	-- body
	self._z = value
end

return cls