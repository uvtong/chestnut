local skynet = require "skynet"
local snax = require "snax"
local errorcode = require "errorcode"
local math3d = require "math3d"
local float = require "float"
local crypt = require "crypt"
local log = require "log"
local list = require "list"
local room_scene = require "room.scene"
local room_player = require "room.player"
local opcodes = require "room.opcodes"
local context = require "room.context"

-- context variable
local ctx
local k = 0
local lasttick = 0
local CMD = {}

--[[
	4 bytes localtime
	4 bytes eventtime		-- if event time is ff ff ff ff , time sync
	4 bytes session
	padding data
]]

-- every frame
local function tick( ... )
	-- body
	while true do 
		k = k + 1
		local t1 = skynet.now()
		local delta = (t1 - lasttick) / 100.0 -- s
		lasttick = t1
		ctx:update(delta, k)		

		skynet.sleep(2)
	end
end

function CMD.update(data)
	assert(#data >= 16)
	local session, protocol = string.unpack("<II", data, 9)	
	local protocol = string.unpack("<I", data, 13)
	if protocol == 1 then
		-- log.info("protocol 1")
		local time = skynet.now()
		data = string.pack("<I", time) .. data
	elseif protocol == 2 then
		local time = skynet.now()
		data = string.pack("<I", time) .. data
		-- data = data:sub(1, 16)
		-- local ball_data = scene:pack_balls()
		-- data = data .. string.pack("<I", 4 + #ball_data) .. string.pack("<I", protocol) .. ball_data
	end
	local gate = ctx:get_gate()
	gate.post.post(session, data)
end

-- called by aoi
function CMD.aoi_message(watcher, marker, ... )
	-- body
	local scene = ctx:get_scene()
	local collision, ball = scene:aoi_check_collision(watcher, marker)
	if collision then
		local player = ball:get_player()
		player:remove(ball)
		local session = player:get_session()
		ctx:broadcast_die({session=session, ballid=ball:get_id()})
	end
end

function CMD.join(handle, secret)
	if ctx:is_maxnum() then
		return false
	end
	local session_players = ctx:get_players()
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
	local gate = ctx:get_gate()
	local session = gate.req.register(skynet.self(), secret)
	local agent = snax.bind(handle, "agent")
	local player = room_player.new(session)
	player:set_secret(secret)
	player:set_agent(agent)
	ctx:add(session, player)

	for k,v in pairs(session_players) do
		if k ~= session then
			log.info("room join")
			local agent = v:get_agent()
			agent.post.join({ session = session })
		end
	end
	return session, ps
end

function CMD.leave(session)
	local gate = ctx:get_gate()
	local scene = ctx:get_scene()
	local session_players = ctx:get_players()
	local player = session_players[session]
	local balls = player:get_balls()
	for k,v in pairs(balls) do
		scene:leave(v:get_id())
	end
	for k,v in pairs(session_players) do
		if k ~= session then
			local agent = v.agent
			agent.post.leave({ session = session })
		end
	end
	gate.req.unregister(session)
	ctx:remove(session)
end

function CMD.query(session)
	local user = users[session]
	-- todo: we can do more
	if user then
		return user.agent.handle
	end
end

function CMD.born(session, ... )
	-- body
	local aoi = ctx:get_aoi()
	local scene = ctx:get_scene()
	local ballid = ctx:gen_ball_id()
	local session_players = ctx:get_players()
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

	for k,v in pairs(session_players) do
		if k ~= session then
			log.info("post born")
			local agent = v:get_agent()
			agent.post.born({ bs = {res} })
		end
	end

	return { errorcode = errorcode.SUCCESS, b = res }
end

function CMD.opcode(session, args, ... )
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

function CMD.start(gate, ... )
	-- body
	ctx:set_gate(gate)
	return true
end

function CMD.close( ... )
	-- body
	for _,user in pairs(users) do
		gate.req.unregister(user.session)
	end
	return true
end

function CMD.kill( ... )
	-- body
	skynet.exit()
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function(_,_, cmd, subcmd, ...)
		local f = CMD[cmd]
		local r = f(subcmd, ... )
		if r ~= nil then
			skynet.ret(skynet.pack(r))
		end
	end)

	ctx = context.new(id) 
	
	-- local aoi = skynet.newservice("aoi")
	-- local conf = {}
	-- conf.handle = snax.self().handle
	-- skynet.call(aoi, "lua", "start", conf)
	-- ctx:set_aoi(aoi)

	-- local scene = room_scene.new(ctx, aoi)
	-- local view = scene:setup_view()
	-- local map = scene:setup_map()
	-- ctx:set_map(map)
	-- ctx:set_view(view)
	-- ctx:set_scene(scene)
end)

