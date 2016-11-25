local log = require "log"
local cls = class("player")

function cls:ctor(session, uid, ... )
	-- body
	self._session = session
	self._uid = uid
	self._secret = nil
	self._agent = nil
	self._car = nil
	self._ai = false
	self._name = "abc"
end

function cls:get_session( ... )
	-- body
	return self._session
end

function cls:set_session(value, ... )
	-- body
	self._session = value
end

function cls:get_uid( ... )
	-- body
	return self._uid
end

function cls:set_uid(value, ... )
	-- body
	self._uid = value
end

function cls:set_secret(v, ... )
	-- body
	self._secret = v
end

function cls:get_secret( ... )
	-- body
	return self._secret
end

function cls:set_agent(v, ... )
	-- body
	self._agent = v
end

function cls:get_agent( ... )
	-- body
	return self._agent
end

function cls:get_car( ... )
	-- body
	return self._car
end

function cls:set_car(value, ... )
	-- body
	self._car = value
end

function cls:get_ai( ... )
	-- body
	return self._ai
end

function cls:set_ai(value, ... )
	-- body
	self._ai = value
end

function cls:get_name( ... )
	-- body
	return self._name
end

function cls:set_name(value, ... )
	-- body
	self._name = value
end

function cls:pack_sproto_balls( ... )
	-- body
	local all = {}
	for k,ball in pairs(self._myballs) do
		local radis = ball:get_radis()
		local length = ball:get_length()
		local width = ball:get_width()
		local height = ball:get_height()
		local res = {}
		res.errorcode = errorcode.SUCCESS
		res.session = ball:get_session()
		res.ballid = ball:get_id()
		res.radis = radis
		res.length = length
		res.width = width
		res.height = height
		res.px = ball:pack_sproto_px()
		res.py = ball:pack_sproto_py()
		res.pz = ball:pack_sproto_pz()
		res.dx = ball:pack_sproto_dx()
		res.dy = ball:pack_sproto_dy()
		res.dz = ball:pack_sproto_dz()
		res.vel = ball:pack_sproto_vel()
		table.insert(all, res)
	end
	return all
end

return cls