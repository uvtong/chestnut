local log = require "log"
local cls = class("player")

function cls:ctor(session, ... )
	-- body
	assert(session)
	self._session = session
	self._myballs = {}
end

function cls:add(ball, ... )
	-- body
	local id = ball:get_id()
	self._myballs[id] = ball
end

function cls:remove(ball, ... )
	-- body
	local id = ball:get_id()
	self._myballs[id] = nil
end

function cls:get_balls( ... )
	-- body
	return self._myballs
end

function cls:change_dir(dir, ... )
	-- body
	local x, y, z = dir:unpack()
	for k,ball in pairs(self._myballs) do
		log.info("before ballid:%d, %d, %d, %d", ball:get_id(), x, y, z)
		ball:set_dir(dir)
		local x, y, z = ball:get_dir():unpack()
		log.info("after ballid:%d, %d, %d, %d", ball:get_id(), x, y, z)
	end
end

return cls