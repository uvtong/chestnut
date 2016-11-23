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
	-- if ctx:get_num() > ctx:get_maxnum() then
	-- 	return false
	-- end
	local session_players = ctx:get_players()
	local ps = {}
	local nps = {}
	for k,player in pairs(session_players) do
		local p = {}
		p.userid = player:get_uid()
		p.carid = 1
		p.ai = false
		table.insert(ps, p)
	end
	local ais = ctx:get_ais()
	for k,player in pairs(ais) do
		local p = {}
		p.userid = player:get_uid()
		p.carid = 1
		p.ai = true
		table.insert(ps, p)
	end

	local gate = ctx:get_gate()
	local session = gate.req.register(skynet.self(), secret)
	local agent = snax.bind(handle, "agent")
	local player = ctx:get_freeplayer()
	player:set_session(session)
	player:set_uid(uid)
	player:set_secret(secret)
	player:set_agent(agent)
	player:set_ai(false)
	
	local key = string.format("%s:%d", "s_attribute", 1)
	local row = sd.query(key)
	local car = car.new(uid)
	car:set_player(player)
	car:set_hp(row.baseHP)

	player:set_car(car)
	ctx:add(uid, player)

	local p = {}
	p.userid = uid
	p.carid = 1
	p.ai = false
	table.insert(nps, p)

	local num = ctx:get_maxnum() - ctx:get_num()
	for i=1,num do
		local uid = skynet.call(".AI_MGR", "lua", "enter")
		local player = ctx:get_freeplayer()
		player:set_session(session)
		player:set_uid(uid)
		player:set_ai(true)
		local car = car.new(uid)
		car:set_player(player)
		car:set_hp(row.baseHP)

		player:set_car(car)
		ctx:add_ai(uid, player)
		
		local p = {}
		p.userid = uid
		p.carid = 1
		p.ai = true
		table.insert(nps, p)
		table.insert(ps, p)
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
			ctx:remove(args.userid)
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
	local hp1 = food:get_hp()
	local hp2 = car:get_hp()
	local hp = hp1 + hp2
	car:set_hp(hp)
	
	local xargs = {}
	xargs.bloodentityLst = { {id=args.id}}
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

function response.start(t, ... )
	-- body
	ctx:start(t)
end

function init(id, udpserver)
	ctx = context.new(id) 
	local gate = snax.bind(udpserver, "udpserver")
	ctx:set_gate(gate)
end

function exit()
	for _,user in pairs(users) do
		gate.req.unregister(user.session)
	end
end
