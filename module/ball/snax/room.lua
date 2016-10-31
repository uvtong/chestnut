local skynet = require "skynet"
local snax = require "snax"
local errorcode = require "errorcode"
local math3d = require "math3d"
local float = require "float"
local crypt = require "crypt"
local log = require "log"
local list = require "list"
local room_scene = require "room.scene"
local rooom_player = require "room.player"
local opcodes = require "room.opcodes"

-- context variable
local max_number = 8
local roomid
local gate
local users = {}
local aoi

local lasttick = 0
local lastmove = 0

-- room object
local map
local view
local scene
local ballid = 1
local session_players = {}

--[[
	4 bytes localtime
	4 bytes eventtime		-- if event time is ff ff ff ff , time sync
	4 bytes session
	padding data
]]

local function gen_ball_id(session, ... )
	-- body
	ballid = ballid + 1
	if ballid <= 0 then
		ballid = 1 
	end
	return ballid
end

local function tick( ... )
	-- body
	while true do 
		skynet.send(aoi, "lua", "message")
		skynet.sleep(4)
	end
end

local function move( ... )
	-- body
	while true do
		local now = skynet.now()
		local delta = (now - lastmove) / 100.0 -- s
		lastmove = now
		scene:move(delta)
		skynet.sleep(2)
	end
end

function accept.update(data)
	local sz = #data
	if sz > 12 then
		local session, protocol = string.unpack("<II", data, 9)
		if protocol == 1 then
			-- local px, py, pz, dx, dy, dz = string.unpack("<ffffff", data, 17)
			-- log.info("px:%f, py:%f, pz:%f, dx:%f, dy:%f, dz:%f", px, py, pz, dx, dy, dz)
			-- local position = math3d.vector3(px, py, pz)
			-- local direction = math3d.vector3(dx, dy, dz)
			
			local time = skynet.now()
			data = string.pack("<I", time) .. data
			data = data:sub(1, 20)

			local player = session_players[session]
			local ball_sz = player:get_balls_sz()
			-- log.info("size of balls of player %d is %d", session, ball_sz)
			if ball_sz > 0 then
				data = data .. string.pack("<I", ball_sz * 32 + 4)
				data = data .. string.pack("<I", ball_sz)
				local balls = player:get_balls()
				for k,ball in pairs(balls) do
					local ballid = string.pack("<j", ball:get_id())
					local pos = ball:pack_pos()
					local dir = ball:pack_dir()
					data = data .. ballid .. pos .. dir	
				end
			else
				data = data .. string.pack("<I", 0)
			end
		end
		for s,v in pairs(users) do
			gate.post.post(s, data)
		end
	else
		log.info("size of data %d", sz)
	end
end

-- called by aoi
function accept.aoi_message(watcher, marker, ... )
	-- body
	scene:aoi_check_collision(watcher, marker)
end

function response.join(handle, secret)
	local n = 0
	for _ in pairs(users) do
		n = n + 1
	end
	if n >= max_number then
		return false	-- max number of room
	end
	local agent = snax.bind(handle, "agent")
	local user = {
		agent = agent,
		key = secret,
		session = gate.req.register(skynet.self(), secret),
	}
	users[user.session] = user
	local player = rooom_player.new(user.session)
	session_players[user.session] = player

	-- return all balls
	local head = scene._list
	local all = {}
	local li = head.next
	while li do
		snax.printf("circle.")
		local ball = li.data
		assert(ball)
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
		li = li.next
	end
	return user.session, all
end

function response.leave(session)
	local player = session_players[session]
	local balls = player:get_balls()
	for k,v in pairs(balls) do
		scene:leave(v:get_id())
	end
	for k,v in pairs(users) do
		if k ~= session then
			local agent = v.agent
			agent.post.leave({ session = session })
		end
	end
	gate.req.unregister(session)
	users[session] = nil
end

function response.query(session)
	local user = users[session]
	-- todo: we can do more
	if user then
		return user.agent.handle
	end
end

function response.born(session, ... )
	-- body
	local ballid = gen_ball_id()
	local ball =assert(scene:setup_ball(ballid, session))

	local player = assert(session_players[session])
	player:add(ball)

	log.info("player %d born ball %d", session, ballid)

	local pos = ball:get_pos()
	local x, y, z = pos:unpack()
	skynet.send(aoi, "lua", "update", ballid, "wm", x, y, z)

	local radis = ball:get_radis()
	local length = ball:get_length()
	local width = ball:get_width()
	local height = ball:get_height()
	local res = {}
	res.errorcode = errorcode.SUCCESS
	res.session = session
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

	for k,v in pairs(users) do
		if k ~= session then
			local agent = v.agent
			agent.post.born({ b = res })
		end
	end

	return { errorcode = errorcode.SUCCESS, b = res }
end

function response.opcode(session, args, ... )
	-- body
	local player = session_players[session]
	if player then
		log.info("has this player")
		if args.code == opcodes.OPCODE_PRESSUP then
			local dir = math3d.vector3(0, 0, 1)
			assert(dir)
			player:change_dir(dir)
		elseif args.code == opcodes.OPCODE_PRESSRIGHT then
			local dir = math3d.vector3(1, 0, 0)
			assert(dir)
			player:change_dir(dir)
		elseif args.code == opcodes.OPCODE_PRESSDOWN then
			local dir = math3d.vector3(0, 0, -1)
			assert(dir)
			player:change_dir(dir)
		elseif args.code == opcodes.OPCODE_PRESSLEFT then
			local dir = math3d.vector3(-1, 0, 0)
			assert(dir)
			player:change_dir(dir)
		end
		return {errorcode = errorcode.SUCCESS}
	else
		log.info("no this player")
		return { errorcode = errorcode.FAIL }
	end
end

function init(id, udpserver)
	roomid = id
	gate = snax.bind(udpserver, "udpserver")
	aoi = skynet.newservice("aoi")
	local conf = {}
	conf.handle = snax.self().handle
	skynet.call(aoi, "lua", "start", conf)
	scene = room_scene.new(aoi)
	view = scene:setup_view()
	map = scene:setup_map()

	lasttick = skynet.now()
	lastmove = skynet.now()
	skynet.fork(tick)
	skynet.fork(move)
end

function exit()
	for _,user in pairs(users) do
		gate.req.unregister(user.session)
	end
end

