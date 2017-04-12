local skynet = require "skynet"
local math3d = require "math3d"
local ball = require "room.ball"
local map = require "room.map"
local view = require "room.view"
local list = require "list"
local log = require "log"
-- local buffgenerate = require "room.BuffGenerate"
local FightingHurt = require "room.FightingHurt"
local cls = class("scene")

function cls:ctor(ctx, aoi, ... )
	-- body
	self._ctx = ctx
	self._aoi = aoi
	self._ballid_balls = {}

	self._view = nil
	self._map = nil

	--self.buffgen = buffgenerate.new()
	--self.buffgen:InitData(1000001,self._ctx)

	self._fighting = FightingHurt.new(ctx, self)
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
	local length = 4.0
	local width = 4.0
	local height = 4.0
	
	local x = math.random(10, 20)
	local y = 5
	local z = math.random(10, 20)
	local position = math3d.vector3(x, y, z)
	local direction = math3d.vector3(0, 0, 0)
	local vel = 0.8
	local accspeed = 1
	local m = 1
	local thrust = 1
	local resistance  = 1

	local b = ball.new(ballid, session, self, radis, length, width, height, position, direction, vel,accspeed,m,thrust,resistance)
	self._ballid_balls[ballid] = b
	return b
end

function cls:leave(ballid, ... )
	-- body
	assert(type(ballid) == "number")
	local ball = assert(self._ballid_balls[ballid])
	local x, y, z = ball:get_pos():unpack()
	skynet.send(self._aoi, "lua", "update", ballid, "d", x, y, z)
	self._ballid_balls[ballid] = nil
end

function cls:move(delta, ... )
	-- body
	local min_x, min_y, min_z = self._map:min():unpack()
	local max_x, max_y, max_z = self._map:max():unpack()
	for k,ball in pairs(self._ballid_balls) do
		local pos = ball:get_pos()
		local dir = ball:get_dir()
		local vel = ball:get_vel()
		local accspeed = ball:get_accspeed()
		local radis = ball:get_radis()

		local dx, dy, dz = dir:unpack()
		local px = dx * (vel * delta+(1/2*accspeed*delta*delta))
		local py = dy * (vel * delta+(1/2*accspeed*delta*delta))
		local pz = dz * (vel * delta+(1/2*accspeed*delta*delta))

		local x, y, z = pos:unpack()
		if (x + px) < (min_x + radis) then
			px = min_x + radis - x
		end
		if (x + px) > (max_x - radis) then
			px = max_x - radis - x
		end
		if (z + pz) < (min_z + radis) then
			pz = min_z + radis - z
		end
		if (z + pz) > (max_z - radis) then
			pz = max_z - radis - z
		end

		ball:move_by(math3d.vector3(px, py, pz))
		local pos = ball:get_pos()
		local x, y, z = pos:unpack()
		-- log.info("ball %f, %f, %f", x, y, z)
		skynet.send(self._aoi, "lua", "update", ball:get_id(), "wm", x, y, z)

		--self.buffgen:checkrectandtimeover(ball)
	end
end

function cls:aoi_check_collision(watcher, marker, ... )
	-- body
	local w = self._ballid_balls[watcher]
	local m = self._ballid_balls[marker]
	if w and m then
		local aabb1 = w:get_aabb()
		local aabb2 = m:get_aabb()
		local center = math3d.vector3(0, 0, 0)
		aabb1:getCenter(center)
		local x, y, z = center:unpack()
		print("aabb1", x, y, z)
		aabb2:getCenter(center)
		local x, y, z = center:unpack()
		print("aabb2", x, y, z)

		if aabb2:intersects(aabb1) then
			local hurt1 = w:get_hurt()
			hurt1:UpdateHurt(m:get_id(), m:get_vel());
			log.info("marker %d enter watcher %d", watcher, marker)
			self._ballid_balls[watcher] = nil
			local x, y, z = w:get_pos():unpack()
			skynet.send(self._aoi, "lua", "update", w:get_id(), "d", x, y, z)
			return true, w
		end
	end
end

function cls:pack_balls( ... )
	-- body
	local sz = 0
	local res = ""
	for k,ball in pairs(self._ballid_balls) do
		sz = sz + 1
		local ballid = string.pack("<j", ball:get_id())
		local pos = ball:pack_pos()
		local dir = ball:pack_dir()
		res = res .. ballid .. pos .. dir
	end
	res = string.pack("<I", sz) .. res
	return res
end

function cls:pack_sproto_balls( ... )
	-- body
	local all = {}
	for k,ball in pairs(self._ballid_balls) do
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