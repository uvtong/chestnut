local log = require "log"
local cls = class("player")

function cls:ctor(session, ... )
	-- body
	assert(session)
	self._session = session
	self._myballs = {}
	self._myballs_sz = 0
end

function cls:get_session( ... )
	-- body
	return self._session
end

function cls:add(ball, ... )
	-- body
	local id = ball:get_id()
	self._myballs[id] = ball
	self._myballs_sz = self._myballs_sz + 1
	ball:set_player(self)
end

function cls:remove(ball, ... )
	-- body
	local id = ball:get_id()
	self._myballs[id] = nil
	self._myballs_sz = self._myballs_sz - 1
	ball:set_player(nil)
end

function cls:get_balls( ... )
	-- body
	return self._myballs
end

function cls:get_balls_sz( ... )
	-- body
	return self._myballs_sz
end

function cls:change_dir(dir, ... )
	-- body
	assert(dir)
	for k,ball in pairs(self._myballs) do
		ball:set_dir(dir)
	end
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