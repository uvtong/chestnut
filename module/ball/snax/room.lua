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
	assert(#data >= 16)
	local session, sz = string.unpack("<II", data, 9)
	if sz > 0 then
		local protocol = string.unpack("<I", data, 17)
		if protocol == 1 then
			local time = skynet.now()
			data = string.pack("<I", time) .. data
			data = data:sub(1, 16)
			local ball_data = scene:pack_balls()
			data = data .. string.pack("<I", 4 + #ball_data) .. string.pack("<I", protocol) .. ball_data
		end
	end
	gate.post.post(session, data)
end

-- called by aoi
function accept.aoi_message(watcher, marker, ... )
	-- body
	local collision, ball = scene:aoi_check_collision(watcher, marker)
	if collision then
		local player = ball:get_player()
		player:remove(ball)
		local session = player:get_session()
		for k,v in pairs(users) do
			local agent = v.agent
			agent.post.die({session=session, ballid=ball:get_id()})	
		end
	end
end

function response.join(handle, secret)
	local n = 0
	for _ in pairs(users) do
		n = n + 1
	end
	if n >= max_number then
		return false	-- max number of room
	end
	local ps = {}
	for k,player in pairs(session_players) do
		local p = {}
		p.session = player:get_session()
		p.balls = {}
		local balls = player:get_balls()
		for k,ball in pairs(balls) do
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
			table.insert(p.balls, res)
		end
		table.insert(ps, p)
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

	for k,v in pairs(users) do
		if k ~= user.session then
			local agent = v.agent
			log.info("room join")
			agent.post.join({ session = user.session })
		end
	end

	return user.session, ps
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
			log.info("post born")
			local agent = v.agent
			agent.post.born({ bs = {res} })
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

