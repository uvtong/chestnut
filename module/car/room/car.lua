local skynet = require "skynet"
local cls = class("car")

function cls:ctor(uid, ... )
	-- body
	self._uid = uid
	self._buff = nil
	self._hp = 0
	return self
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

return cls