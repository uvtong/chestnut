local skynet = require "skynet"
local skynet_queue = require "skynet.queue"
local snax = require "snax"
local errorcode = require "errorcode"
local math3d = require "math3d"
local float = require "float"
local crypt = require "crypt"
local log = require "log"
local list = require "list"
local sd = require "sharedata"
local player = require "room.player"
local context = require "room.rcontext"
local buff = require "room.buff"
local car = require "room.car"
local recover_buff = require "room.recover_buff"
local accel_buff = require "room.accel_buff"
local decel_buff = require "room.decel_buff"
local harm_buff = require "room.harm_buff"
local hurt_buff = require "room.hurt_buff"
local shield_buff = require "room.shield_buff"
local weak_buff = require "room.weak_buff"

-- context variable
local ctx
local k = 0
local lasttick = 0

--[[
	4 bytes localtime
	4 bytes eventtime		-- if event time is ff ff ff ff , time sync
	4 bytes session
	padding data
]]
function accept.update(data)
	-- log.info("test")
	assert(#data >= 16)
	local session, protocol = string.unpack("<II", data, 9)	
	-- local protocol = string.unpack("<I", data, 13)
	if protocol == 1 then
		local _, uid, x, y, z = string.unpack("<IIfff", data, 17)
		local player
		if uid < 1000 then
			player = ctx:get_ai(uid)
		else
			player = ctx:get_player(uid)
		end
		if player then
			local car = player:get_car()
			car:set_x(x)
			car:set_y(y)
			car:set_z(z)
		end
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
	local session_players = ctx:get_players()
	for k,v in pairs(session_players) do
		-- if session ~= v:get_session() then
		-- 	gate.post.post(v:get_session(), data)
		-- end
		gate.post.post(v:get_session(), data)
	end
end

function response.joinroom(handle, secret, uid)
	log.info("uid: %d", uid)
	local session_players = ctx:get_players()
	local ps = {}
	local nps = {}
	for k,player in pairs(session_players) do
		local p = {}
		p.userid = player:get_uid()
		p.carid = player:get_car():get_id()
		p.ai = player:get_ai()
		p.name = player:get_name()
		p.x = math.tointeger(player:get_car():get_x())
		p.y = math.tointeger(player:get_car():get_y())
		p.z = math.tointeger(player:get_car():get_z())
		p.ori = player:get_car():get_ori()
		table.insert(ps, p)
		-- print(p.userid, p.carid, p.ai, p.x, p.y, p.z, p.ori)
	end
	local ais = ctx:get_ais()
	for k,player in pairs(ais) do
		local p = {}
		p.userid = player:get_uid()
		p.carid = player:get_car():get_id()
		p.ai = player:get_ai()
		p.name = player:get_name()
		p.x = math.tointeger(player:get_car():get_x())
		p.y = math.tointeger(player:get_car():get_y())
		p.z = math.tointeger(player:get_car():get_z())
		p.ori = player:get_car():get_ori()
		table.insert(ps, p)
		-- print(p.userid, p.carid, p.ai, p.x, p.y, p.z, p.ori)
	end

	local gate = ctx:get_gate()
	local session = gate.req.register(skynet.self(), secret)
	local agent = snax.bind(handle, "agent")
	local player = ctx:create_player()
	player:set_session(session)
	player:set_uid(uid)
	player:set_secret(secret)
	player:set_agent(agent)
	player:set_ai(false)
	player:set_name("abc")
	
	local key = string.format("%s:%d", "s_attribute", 1)
	local row = sd.query(key)
	local car = car.new(1, uid)
	car:set_player(player)
	car:set_hp(row.baseHP)
	local q1 = ctx:get_q1()
	if q1:size() > 0 then
		local pos = q1:dequeue()
		car:set_x(math.tointeger(pos[1]))
		car:set_y(math.tointeger(pos[2]))
		car:set_z(math.tointeger(pos[3]))
		local ori = math.random(1, 360)
		car:set_ori(ori)
		q1:enqueue(pos)
	else
		assert(q2:size() > 0)
		local q2 = ctx:get_q2()
		local pos = q2:dequeue()
		car:set_x(math.tointeger(pos[1]))
		car:set_y(math.tointeger(pos[2]))
		car:set_z(math.tointeger(pos[3]))
		local ori = math.random(1, 360)
		car:set_ori(ori)
		q2:enqueue(pos)
	end

	player:set_car(car)
	ctx:add(uid, player)
	local leadboard = ctx:get_leadboard()
	local function comp(p1, p2, ... )
		-- body
		if p1:get_score() > p2:get_score() then
			return true
		else
			return false
		end
	end
	leadboard:push_back(player, comp)

	local p  = {}
	p.userid = uid
	p.carid  = car:get_id()
	p.ai     = player:get_ai()
	p.name   = player:get_name()
	p.x   = math.tointeger(player:get_car():get_x())
	p.y   = math.tointeger(player:get_car():get_y())
	p.z   = math.tointeger(player:get_car():get_z())
	p.ori = car:get_ori()
	table.insert(nps, p)
	table.insert(ps, p)
	-- print(p.userid, p.carid, p.ai, p.x, p.y, p.z, p.ori)

	-- create ai
	local num = ctx:get_ainumber() - ctx:get_ai_sz()
	log.info("ai num: %d", num)
	for i=1,num do
		local player = ctx:alloc_ai(row.baseHP)
		player:set_session(session)
		ctx:add_ai(player:get_uid(), player)
		
		local car = player:get_car()
		local q1 = ctx:get_q1()
		if q1:size() > 0 then
			local pos = q1:dequeue()
			car:set_x(math.tointeger(pos[1]))
			car:set_y(math.tointeger(pos[2]))
			car:set_z(math.tointeger(pos[3]))
			local ori = math.random(1, 360)
			car:set_ori(ori)
			q1:enqueue(pos)
		else
			local q2 = self:get_q2()
			local pos = q2:dequeue()
			car:set_x(math.tointeger(pos[1]))
			car:set_y(math.tointeger(pos[2]))
			car:set_z(math.tointeger(pos[3]))
			local ori = math.random(1, 360)
			car:set_ori(ori)
			q2:enqueue(pos)
		end
		local u = ctx:get_player(uid)
		u:add_ai(player)

		local p  = {}
		p.userid = player:get_uid()
		p.carid  = player:get_car():get_id()
		p.ai     = player:get_ai()
		p.name   = player:get_name()
		p.x = math.tointeger(car:get_x())
		p.y = math.tointeger(car:get_y())
		p.z = math.tointeger(car:get_z())
		p.ori = car:get_ori()
		table.insert(nps, p)
		table.insert(ps, p)
		-- print(p.userid, p.carid, p.ai, p.x, p.y, p.z, p.ori)
	end

	if ctx:get_number() == ctx:get_players_sz() then
		log.info("countdown limit_start. num of players: %d", ctx:get_number())
		local function countdown( ... )
			-- body
			for k,v in pairs(session_players) do
				local agent = v:get_agent()
				agent.post.limit_start()
			end			
		end
		skynet.timeout(100 * 1, countdown)
	end

	for k,v in pairs(session_players) do
		if v:get_session() ~= session then
			log.info("room joinroom %d", uid)
			local agent = v:get_agent()
			agent.post.joinroom({ battleinitdataitem=nps })
		end
	end
	return session, ps
end

function response.leave(args)
	if args.userid then
		local player
		if args.userid < 1000 then
			ctx:remove_ai(args.userid)
		else
			-- remove player ai
			player = ctx:get_player(args.userid)
			assert(player)
			local ais = player:get_ais()
			for k,v in pairs(ais) do
				player:remove_ai(v)
			end
			ctx:remove(args.userid)

			-- -- change_ai
			-- if ctx:get_players_sz() > 0 then
			-- 	local player
			-- 	local players = ctx:get_players()
			-- 	for k,v in pairs(players) do
			-- 		player = v
			-- 		break
			-- 	end
			-- 	local ps = {}
			-- 	for k,player in pairs(ais) do
			-- 		local p = {}
			-- 		p.userid = player:get_uid()
			-- 		p.carid = player:get_car():get_id()
			-- 		p.ai = player:get_ai()
			-- 		p.name = player:get_name()
			-- 		p.x = math.tointeger(car:get_x())
			-- 		p.y = math.tointeger(car:get_y())
			-- 		p.z = math.tointeger(car:get_z())
			-- 		p.ori = car:get_ori()
			-- 		table.insert(ps, p)
			-- 	end
			-- 	local agent = player:get_agent()
			-- 	agent.post.change_ai({battleinitdataitem=ps})
			-- else
			-- 	if ctx:get_type() == 1 then
			-- 		local id = ctx:get_id()
			-- 		skynet.send(".ROOM_MGR", "lua", "enqueue_room", id)
			-- 	end
			-- end
		end
		local players = ctx:get_players()
		for k,v in pairs(players) do
			local agent = v:get_agent()
			agent.post.exitroom(args)
		end

		-- local balls = player:get_balls()
		-- for k,v in pairs(balls) do
		-- 	scene:leave(v:get_id())
		-- end
		-- for k,v in pairs(session_players) do
		-- 	if k ~= session then
		-- 		local agent = v.agent
		-- 		agent.post.leave({ session = session })
		-- 	end
		-- end
	end
end

function response.query(session)
	local user = users[session]
	-- todo: we can do more
	if user then
		return user.agent.handle
	end
end

function response.createbuff(args, ... )
	-- body
	log.info("userid: %d createbuff", tonumber(args.userid))
	local player
	if args.userid < 1000 then
		player = ctx:get_ai(args.userid)
	else
		player = ctx:get_player(args.userid)
	end
	local car = player:get_car()
	local id = args.buff_id
	local b = nil
	local raw = nil
	if id == 1 then
		local key = string.format("%s:%d", "s_buff", id)
		raw = sd.query(key)
		local limit = raw.continuedtime
		b = accel_buff.new(ctx, id, buff.type.SINGLE, limit * 100)
	elseif id == 2 then
		local key = string.format("%s:%d", "s_buff", id)
		raw = sd.query(key)
		local limit = raw.continuedtime
		b = recover_buff.new(ctx, id, buff.type.SINGLE, limit * 100, raw.hpadd)
	elseif id == 3 then
		local key = string.format("%s:%d", "s_buff", id)
		raw = sd.query(key)
		local limit = raw.continuedtime
		b = harm_buff.new(ctx, id, buff.type.SINGLE, limit * 100)
	elseif id == 4 then
		local key = string.format("%s:%d", "s_buff", id)
		raw = sd.query(key)
		local limit = raw.continuedtime
		b = shield_buff.new(ctx, id, buff.type.SINGLE, limit * 100)
	elseif id == 5 then
		local key = string.format("%s:%d", "s_buff", id)
		raw = sd.query(key)
		local limit = raw.continuedtime
		b = decel_buff.new(ctx, id, buff.type.SINGLE, limit * 100)
	elseif id == 6 then
		local key = string.format("%s:%d", "s_buff", id)
		raw = sd.query(key)
		local limit = raw.continuedtime
		local b = shield_buff.new(ctx, id, buff.type.SINGLE, limit * 100)
	elseif id == 7 then
		local key = string.format("%s:%d", "s_buff", id)
		raw = sd.query(key)
		local limit = raw.continuedtime
		b = hurt_buff.new(ctx, id, buff.type.SINGLE, limit * 100)
	elseif id == 8 then
	elseif id == 9 then
	end
	assert(b)
	local last = car:get_buff()
	if last then
		last:die()
		car:set_buff(nil)
	end
	assert(car:get_buff() == nil)
	car:set_buff(buff)
	b:set_parent(car)

	local args = {}
	args.userid = player:get_uid()
	args.buffid = id
	local session_players = ctx:get_players()
	for k,v in pairs(session_players) do
		local agent = v:get_agent()
		agent.post.createbuff(args)
	end
	
	if id == 1 then
		args.value = raw.accelerateadd
	elseif id == 2 then
		args.value = 0
	elseif id == 3 then
		args.value = raw.damageadd
	elseif id == 4 then
		args.value = raw.invinciblecount
	elseif id == 5 then
		args.value = raw.accelerateminus
	elseif id == 6 then
		args.value = 0
	elseif id == 7 then
		args.value = raw.damageminus
	end
	local session_players = ctx:get_players()
	for k,v in pairs(session_players) do
		local agent = v:get_agent()
		agent.post.dealbuffvalue(args)
	end

	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function response.updateblood(args, ... )
	-- body
	local player
	if args.targetuserid < 1000 then
		player = ctx:get_ai(args.targetuserid)
	else
		player = ctx:get_player(args.targetuserid)
	end
	assert(player)
	local car = player:get_car()
	local hp = car:get_hp()
	hp = hp - args.bloodvalue
	car:set_hp(hp)
	args.bloodvalue = hp
	local players = ctx:get_players()
	for k,v in pairs(players) do
		local agent = v:get_agent()
		agent.post.updateblood(args)
	end
	if hp <= 0 then
		local xargs = {}
		xargs.userid = player:get_uid()
		local players = ctx:get_players()
		for k,v in pairs(players) do
			local agent = v:get_agent()
			agent.post.die(xargs)
		end

		-- attack kill num
		local attack
		if args.sourceuserid < 1000 then
			attack = ctx:get_ai(args.sourceuserid)
		else
			attack = ctx:get_ai(args.sourceuserid)
		end
		if attack then
			local kill = attack:get_kill()
			kill = kill + 1
			attack:set_kill(kill)
		end

		local agent = attack:get_agent()
		agent.post.cur_info({ cur_kill=kill, cur_score=attack:get_score()})

		local x = car:get_x()
		local y = car:get_y()
		local z = car:get_z()
		local food_mgr = ctx:get_food_mgr()
		food_mgr:gen_cus(math.tointeger(x), 0, math.tointeger(z))

		if player:get_id() then
			ctx:remove_ai(player:get_uid())
		else
			ctx:remove(player:get_uid())
		end

		local num = ctx:get_maxnum() - ctx:get_num()
		if num > 0 then
			local nps = {}
			for i=1,num do
				local uid = skynet.call(".AI_MGR", "lua", "enter")
				local player = ctx:get_freeplayer()
				player:set_session(session)
				player:set_uid(uid)
				player:set_ai(true)
				local car = car.new(uid)
				car:set_player(player)
				car:set_hp(row.baseHP)
				ctx:add_ai(player)
				
				local p = {}
				p.userid = uid
				p.carid = 1
				p.ai = true
				table.insert(nps, p)
			end

			for k,v in pairs(session_players) do
				local agent = v:get_agent()
				agent.post.joinroom({ battleinitdataitem=nps })
			end
		end
	end
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function response.eitbloodentity(args, ... )
	-- body
	log.info("userid:%d, id:%d", args.userid, args.id)
	local food_mgr = ctx:get_food_mgr()
	local food = food_mgr:get_food(args.id)
	food_mgr:remove(args.id)

	local player
	if args.userid < 1000 then
		player = ctx:get_ai(args.userid)
	else
		player = ctx:get_player(args.userid)
	end
	local car = player:get_car()
	-- cal hp
	local hp1 = food:get_hp()
	local hp2 = car:get_hp()
	local hp = hp1 + hp2
	car:set_hp(hp)
	-- cal score
	local score1 = food:get_fraction()
	local score2 = player:get_score()
	local score = score1 + score2
	player:set_score(score)
	ctx:push_leadboard(player)
	
	
	local xargs = {}
	xargs.bloodentityLst = {{ id=args.id}}
	local players = ctx:get_players()
	for k,v in pairs(players) do
		local agent = v:get_agent()
		agent.post.deletebloodentity(xargs)
	end
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function response.die(args, ... )
	-- body
	if args.userid < 1000 then
		ctx:remove_ai(args.userid)
	else
		ctx:remove(args.userid)
	end

	local players = ctx:get_players()
	for k,v in pairs(players) do
		local agent = v:get_agent()
		agent.post.die(args)
	end
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function response.start(mgr, udpserver, t, total, users, ais, ... )
	-- body
	local room_mgr = snax.bind(mgr, "roomkeeper")
	ctx:set_room_mgr(room_mgr)
	local gate = snax.bind(udpserver, "udpserver")
	ctx:set_gate(gate)
	ctx:start(t, total, users, ais)
end

function response.close( ... )
	-- body
	local gate = ctx:get_gate()
	local players = ctx:get_players()
	for k,player in pairs(players) do
		local session = player:get_session()
		gate.req.unregister(session)	
	end

	local id = ctx:get_id()
	local room_mgr = ctx:get_room_mgr()
	room_mgr.post.exit(id)
end

function accept.kill( ... )
	-- body
	skynet.exit()
end

function init(id, udpserver)
	ctx = context.new(id) 
	-- local gate = snax.bind(udpserver, "udpserver")
	-- ctx:set_gate(gate)
end

function exit()
	local gate = ctx:get_gate()
	local players = ctx:get_players()
	for _,p in pairs(players) do
		gate.req.unregister(p:get_session())
	end
end
