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
	assert(agent and session and ballid)
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
	self._ballid_balls[ballid] = b
	list.add(self._list, b)
	return b
end

function cls:update_ball(delta, ballid, pos, dir, ... )
	-- body
	local ball = self._ballid_balls[ballid]
	ball:set_dir(dir)
	local vel = ball:get_vel()
	local x, y, z = dir:unpack()
	x = x * vel
	y = y * vel
	z = z * vel
	local position = math3d.vector3(x, y, z)
	ball:move_to(position)
end

function cls:leave(ballid, ... )
	-- body
	local ball = self._ballid_balls[ballid]
	list.del(self._list, ball)
	self._ballid_balls[ballid] = nil
end

function cls:move(delta, ... )
	-- body
	local node = self._list.next
	while node do
		local ball = node.data
		local dir = ball:get_dir()
		local vel = ball:get_vel()
		local dx, dy, dz = dir:unpack()
		-- log.info("ballid:%d, %d, %d, %d", ball:get_id(), dx, dy, dz)
		local px = dx * vel * delta
		local py = dy * vel * delta
		local pz = dz * vel * delta
		ball:move_by(px, py, pz)
		log.info("ballid:%d, %d, %d, %d", ball:get_id(), px, py, pz)
		node = node.next
	end
end

return cls