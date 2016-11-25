local cls = class("food")

function cls:ctor(id, type, hp, ... )
	-- body
	self._id = id
	self._type = type
	self._hp = hp
	self._x = 0
	self._y = 0
	self._z = 0
	self._fraction = 0
	return self
end

function cls:get_id( ... )
	-- body
	return self._id
end

function cls:set_id(value, ... )
	-- body
	self._id = value
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

function cls:get_fraction( ... )
	-- body
	return self._fraction
end

function cls:set_fraction(value, ... )
	-- body
	self._fraction = value
end

return cls