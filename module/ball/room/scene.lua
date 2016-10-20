local skynet = require "skynet"
local math3d = require "math3d"
local ball = require "room.ball"
local map = require "room.map"
local view = require "room.view"
local list = require "list"
local log = require "log"
local cls = class("scene")

function cls:ctor(env, ... )
	-- body
	self._env = env
	self._ballid_balls = {}
	self._list = list.new()

	self._view = nil
	self._map = nil
end

function cls:update(watcher, marker, ... )
	-- body
	local w = self._session_balls[watcher]
	local m = self._session_balls[marker]
	if w and m then
		local aabb1 = w:get_aabb()
		local aabb2 = m:get_aabb()
		if aabb1:intersects(aabb2) then
			log.info("marker %d enter watcher %d", watcher, marker)
		end
	end
end

function cls:setup_view( ... )
	-- body
	self._view = view.new(self)
	return self._view
end

function cls:setup_map( ... )
	-- body
	self._map = map.new(self)
	return self._map
end

function cls:setup_ball(agent, session, ballid, ... )
	-- body
	assert(agent and session)
	local radis = 4.0 -- 1 unity
	local length = 3.0
	local width = 3.0
	local height = 3.0
	
	local x = math.random(10, 20)
	local y = 5
	local z = math.random(10, 20)
	local position = math3d.vector3(x, y, z)
	local direction = math3d.vector3(0, 0, 0)
	local vel = 1.0

	local b = ball.new(ballid, self, agent, session, radis, length, width, height, position, direction, vel)
	self._session_balls[session] = b
	list.add(self._list, b)
	return b
end

function cls:update_ball(delta, session, pos, dir, ... )
	-- body
	local ball = self._session_balls[session]
	ball:move_to(pos)
	ball:set_dir(dir)
end

function cls:leave(session, ... )
	-- body
	local ball = self._session_balls[session]
	list.del(self._list, ball)
	self._session_balls[session] = nil
end

return cls