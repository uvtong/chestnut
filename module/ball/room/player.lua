local log = require "log"
local cls = class("player")

function cls:ctor(session, ... )
	-- body
	assert(session)
	self._session = session
	self._myballs = {}
	self._myballs_sz = 0
end

function cls:add(ball, ... )
	-- body
	local id = ball:get_id()
	self._myballs[id] = ball
	self._myballs_sz = self._myballs_sz + 1
end

function cls:remove(ball, ... )
	-- body
	local id = ball:get_id()
	self._myballs[id] = nil
	self._myballs_sz = self._myballs_sz - 1
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

return cls