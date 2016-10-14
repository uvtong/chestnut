local skynet = require "skynet"
local math3d = require "math3d"
local ball = require "room.ball"
local map = require "room.map"
local list = require "list"
local log = require "log"
local cls = class("scene")

function cls:ctor(env, ... )
	-- body
	self._env = env
	self._session_balls = {}
	self._list = list.new()
	self._map = nil
	self._lastTi = skynet.now()
end

function cls:create_map( ... )
	-- body
	self._map = map.new()
	return self._map
end

function cls:born(agent, session, ... )
	-- body
	assert(agent and session)
	local radis = 4.0 -- 1 unity
	local length = 3.0
	local width = 3.0
	local height = 3.0
	
	local x = math.random(10, 20)
	local y = math.random(10, 20)
	local z = 5
	local position = math3d.vector3(x, y, z)
	local direction = math3d.vector3(1, 0, 0)
	local vel = 1.0

	local b = ball.new(agent, session, radis, length, width, height, position, direction, vel)
	self._session_balls[session] = b
	list.add(self._list, b)
	return b
end


function cls:update(session, position, direction, ... )
	-- body
	local now = skynet.now()
	local delta = now - self._lastTi
	
	local b = self._session_balls[session]
	b:move_to(position)
	b:set_direction(direction)
	
	-- local ball = self._list.next
	-- while ball do
	-- 	if ball ~= b then
	-- 		local aabb1 = b:get_aabb()
	-- 		local aabb2 = ball:get_aabb()
	-- 		if aabb1:intersects(aabb2) then
	-- 		end
	-- 	end
	-- end
end

function cls:leave(session, ... )
	-- body
	local ball = self._session_balls[session]
	list.del(self._list, ball)
	self._session_balls[session] = nil
end

return cls