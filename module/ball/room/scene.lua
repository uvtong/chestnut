local skynet = require "skynet"
local math3d = require "math3d"
local ball = require "room.ball"
local map = require "room.map"
local view = require "room.view"
local list = require "list"
local log = require "log"
local cls = class("scene")

function cls:ctor(aoi, ... )
	-- body
	self._aoi = aoi
	self._ballid_balls = {}
	self._list = list.new()

	self._view = nil
	self._map = nil
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

function cls:setup_ball(ballid, session, ... )
	-- body
	assert(ballid and session)
	local radis = 4.0 -- 1 unity
	local length = 3.0
	local width = 3.0
	local height = 3.0
	
	local x = math.random(10, 20)
	local y = 5
	local z = math.random(10, 20)
	local position = math3d.vector3(x, y, z)
	local direction = math3d.vector3(0, 0, 0)
	local vel = 0.8

	local b = ball.new(ballid, session, self, radis, length, width, height, position, direction, vel)
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
	assert(type(ballid) == "number")
	local ball = self._ballid_balls[ballid]
	local x, y, z = ball:get_pos():unpack()
	skynet.send(self._aoi, "lua", "update", ballid, "d", x, y, z)
	list.del(self._list, ball)
	self._ballid_balls[ballid] = nil
end

function cls:move(delta, ... )
	-- body
	local min_x, min_y, min_z = self._map:min():unpack()
	local max_x, max_y, max_z = self._map:max():unpack()
	local node = self._list.next
	while node do
		local ball = node.data
		local pos = ball:get_pos()
		local dir = ball:get_dir()
		local vel = ball:get_vel()
		local radis = ball:get_radis()

		local dx, dy, dz = dir:unpack()
		local px = dx * vel * delta
		local py = dy * vel * delta
		local pz = dz * vel * delta

		local x, y, z = pos:unpack()
		x = x + px
		y = y + py
		z = z + pz

		if x - radis < min_x then
			x = min_x + radis
		end
		if x + radis > max_x then
			x = max_x - radis
		end
		if z - radis < min_z then
			z = min_z + radis
		end
		if z + radis > max_z then
			z = max_z - radis
		end

		ball:move_to(math3d.vector3(x, y, z))
		skynet.send(self._aoi, "lua", "update", ball:get_id(), "wm", x, y, z)
		node = node.next
	end
end

function cls:aoi_check_collision(watcher, marker, ... )
	-- body
	local w = self._ballid_balls[watcher]
	local m = self._ballid_balls[marker]
	if w and m then
		local aabb1 = w:get_aabb()
		local aabb2 = m:get_aabb()
		if aabb1:intersects(aabb2) then
			log.info("marker %d enter watcher %d", watcher, marker)
		end
	end
end

return cls