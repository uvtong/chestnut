local skynet = require "skynet"
require "skynet.manager"
local const = require "const"

local cls = class("agent_context")

function cls:ctor( ... )
	-- body
	self._host = false
	self._send_request = false
	self._gate = false
	self._userid = false
	self._subid = false
	self._secret = false
	self._db = false
	self._game = false
	self._user = false
	self._center = false

	local cls = require "notification_center"	
	local center = cls.new()
	self._center = center
	center:register(center.events.EGOLD, self.handler_egold, self)
	center:register(center.events.EEXP, self.handler_eexp, self)
	center:register(center.events.EUSER_LEVEL, self.handler_user_level, self)

	cls = require "factory"
	local myfactory = cls.new(self, self._user)
	self._myfactory = myfactory

	cls = require "load_user"
	local modelmgr = cls.new(self)
	self._modelmgr = modelmgr

	cls = require "arena"
	local arena = cls.new()
	self._arena = arena

	cls = require "models/usersmgr"
	local usersmgr = cls.new()
	self._usersmgr = usersmgr
end

function cls:get_usersmgr( ... )
	-- body
	return self._usersmgr
end

function cls:get_modelmgr( ... )
	-- body
	return self._modelmgr
end

function cls:set_usersmgr(v, ... )
	-- body
	self._usersmgr = v
end

function cls:get_usersmgr( ... )
	-- body
	return self._usersmgr
end

function cls:get_myfactory( ... )
	-- body
	return self._myfactory
end

function cls:handler_egold( ... )
	-- body
	self:raise_achievement(const.ACHIEVEMENT_T_2)
end

function cls:handler_eexp( ... )
	-- body
 	self:raise_achievement(const.ACHIEVEMENT_T_3)
end

function cls:handler_user_level( ... )
	-- body
	self:raise_achievement(const.ACHIEVEMENT_T_7)
end

function cls:get_game( ... )
	-- body
	return self._game
end

function cls:set_game(v, ... )
	-- body
	self._game = v
end

function cls:get_notification( ... )
	-- body
	return self._center
end

function cls:get_host( ... )
	-- body
	return self._host
end

function cls:set_host(v)
	-- body
	if self._host == false then
		self._host = v
	end
end

function cls:get_send_request( ... )
	-- body
	return self._send_request
end

function cls:set_send_request(v)
	-- body
	self._send_request = true
end

function cls:get_gate( ... )
	-- body
	return self._gate
end

function cls:set_gate(v, ... )
	-- body
	self._gate = v
end

function cls:get_userid( ... )
	-- body
	return self._userid
end

function cls:set_userid(v, ... )
	-- body
	self._userid = v
end

function cls:get_subid( ... )
	-- body
	return self._subid
end

function cls:set_subid(v, ... )
	-- body
	self._subid = v
end

function cls:get_secret( ... )
	-- body
	return self._secret
end

function cls:set_secret(v, ... )
	-- body
	self._secret = v
end

function cls:get_db( ... )
	-- body
	return self._db
end

function cls:set_db(v, ... )
	-- body
	self._db = v
end

function cls:get_user( ... )
	-- body
	return self._user
end

function cls:set_user(v, ... )
	-- body
	self._user = v
end

function cls:get_arena( ... )
	-- body
	return self._arena
end

function cls:set_arena(v, ... )
	-- body
	self._arena = v
end

function cls:raise_achievement(T)
	-- body
	assert(T)
	while true do 
		local a = assert(self._user.u_achievementmgr:get_by_type(T))
		if a.unlock_next_csv_id == 0 then
			break
		end
		local finished
		if T == const.ACHIEVEMENT_T_2 then
			finished = self._user.u_propmgr:get_by_csv_id(const.GOLD).num
		elseif T == const.ACHIEVEMENT_T_3 then
			finished = self._user.u_propmgr:get_by_csv_id(const.EXP).num
		elseif T == const.ACHIEVEMENT_T_4 then
			finished = self._user.take_diamonds
		elseif T == const.ACHIEVEMENT_T_5 then
			finished = self._user.u_rolemgr:get_count()
		elseif T == const.ACHIEVEMENT_T_6 then
			finished = self._user.u_checkpointmgr:get_by_csv_id(0).chapter
		elseif T == const.ACHIEVEMENT_T_7 then
			finished = self._user.level
		elseif T == const.ACHIEVEMENT_T_8 then
			finished = self._user.draw_number
		elseif T == const.ACHIEVEMENT_T_9 then
			finished = self._user.u_kungfumgr:get_count()
		else
			assert(false)
		end
		local progress = finished / a.c_num
		if progress >= 1 then
			local tmp = {}
			for k,v in pairs(a) do
				tmp[k] = v
			end
			tmp.finished = 100
			tmp.reward_collected = 0
			self:push_achievement(a)

			local rc = self._user.u_achievement_rcmgr:create(tmp)
			self._user.u_achievement_rcmgr:add(rc)
			rc:__insert_db(const.DB_PRIORITY_2)

			assert(type(a.unlock_next_csv_id), string.format("%s", type(a.unlock_next_csv_id)))
			local ga = skynet.call(self._game, "lua", "query_g_achievement", a.unlock_next_csv_id)
			a.csv_id = ga.csv_id
			a.finished = 0
			a.c_num = ga.c_num
			a.unlock_next_csv_id = ga.unlock_next_csv_id
			a.is_unlock = 1
		else
			a.finished = math.floor(progress * 100)
			break
		end
	end
end

function cls:xilian(role, t)
	-- body
	assert(type(t) == "table")
	local ret = {}
	local property_pool = skynet.call(self._game, "lua", "query_g_property_pool")
	local last = 0
	local sum = 0
	for k,v in pairs(property_pool) do
		v.min = last
		sum = sum + v.probability
		v.max = sum
	end
	local n = 0
	if t.is_locked1 then
		n = n + 1
		ret.property_id1 = role.property_id1
		ret.value1 = role.value1
	else
		local property_pool_id
		local rand = math.random(0, sum-1)
		for k,v in pairs(property_pool) do
			if rand >= v.min and rand < v.max then
				property_pool_id = v.property_pool_id
				break
			end
		end
		assert(property_pool_id)
		property_pool_id = 1
		local last1 = 0
		local sum1 = 0
		local second = skynet.call(self._game, "lua", "query_g_property_pool_second", 0, property_pool_id)
		for i,v in ipairs(second) do
			v.min = last1
			sum1 = sum1 + v.probability
			v.max = sum1
		end
		rand = math.random(0, sum1-1)
		for i,v in ipairs(second) do
			if rand >= v.min and rand < v.max then
				ret.property_id1 = v.property_id
				ret.value1 = v.value
				break
			end
		end
	end

	if t.is_locked2 then
		n = n + 1
		ret.property_id2 = role.property_id2
		ret.value2 = role.value2
	else
		local property_pool_id
		local rand = math.random(0, sum-1)
		for k,v in pairs(property_pool) do
			if rand >= v.min and rand < v.max then
				property_pool_id = v.property_pool_id
				break
			end
		end
		assert(property_pool_id)
		property_pool_id = 1
		local last1 = 0
		local sum1 = 0
		local second = skynet.call(self._game, "lua", "query_g_property_pool_second", 0, property_pool_id)
		for i,v in ipairs(second) do
			v.min = last1
			sum1 = sum1 + v.probability
			v.max = sum1
		end
		rand = math.random(0, sum1-1)
		for i,v in ipairs(second) do
			if rand >= v.min and rand < v.max then
				ret.property_id2 = v.property_id
				ret.value2 = v.value
				break
			end
		end
	end

	if t.is_locked3 then
		n = n + 1
		ret.property_id3 = role.property_id3
		ret.value3 = role.value3
	else
		local property_pool_id
		local rand = math.random(0, sum-1)
		for k,v in pairs(property_pool) do
			if rand >= v.min and rand < v.max then
				property_pool_id = v.property_pool_id
				break
			end
		end
		assert(property_pool_id)
		property_pool_id = 1
		local last1 = 0
		local sum1 = 0
		local second = skynet.call(self._game, "lua", "query_g_property_pool_second", 0, property_pool_id)
		for i,v in ipairs(second) do
			v.min = last1
			sum1 = sum1 + v.probability
			v.max = sum1
		end
		rand = math.random(0, sum1-1)
		for i,v in ipairs(second) do
			if rand >= v.min and rand < v.max then
				ret.property_id3 = v.property_id
				ret.value3 = v.value
				break
			end
		end
	end

	if t.is_locked4 then
		n = n + 1
		ret.property_id4 = role.property_id4
		ret.value4 = role.value4
	else
		local property_pool_id
		local rand = math.random(0, sum-1)
		for k,v in pairs(property_pool) do
			if rand >= v.min and rand < v.max then
				property_pool_id = v.property_pool_id
				break
			end
		end
		assert(property_pool_id)
		property_pool_id = 1
		local last1 = 0
		local sum1 = 0
		local second = skynet.call(self._game, "lua", "query_g_property_pool_second", 0, property_pool_id)
		for i,v in ipairs(second) do
			v.min = last1
			sum1 = sum1 + v.probability
			v.max = sum1
		end
		rand = math.random(0, sum1-1)
		for i,v in ipairs(second) do
			if rand >= v.min and rand < v.max then
				ret.property_id4 = v.property_id
				ret.value4 = v.value
				break
			end
		end
	end

	if t.is_locked5 then
		n = n + 1
		ret.property_id5 = role.property_id5
		ret.value5 = role.value5
	else
		local property_pool_id
		local rand = math.random(0, sum-1)
		for k,v in pairs(property_pool) do
			if rand >= v.min and rand < v.max then
				property_pool_id = v.property_pool_id
				break
			end
		end
		assert(property_pool_id)
		property_pool_id = 1
		local last1 = 0
		local sum1 = 0
		local second = skynet.call(self._game, "lua", "query_g_property_pool_second", 0, property_pool_id)
		for i,v in ipairs(second) do
			v.min = last1
			sum1 = sum1 + v.probability
			v.max = sum1
		end
		rand = math.random(0, sum1-1)
		for i,v in ipairs(second) do
			if rand >= v.min and rand < v.max then
				ret.property_id5 = v.property_id
				ret.value5 = v.value
				break
			end
		end
	end
	return n, ret
end

function cls:role_recruit(csv_id)
	-- body
	assert(csv_id)
	local role = skynet.call(".game", "lua", "query_g_role", csv_id)
	local us = skynet.call(".game", "lua", "query_g_role_star", role.csv_id*1000 + role.star)
	local prop = self.user.u_propmgr:get_by_csv_id(role.us_prop_csv_id)
	if prop and prop.num >= assert(us.us_prop_num) then
		prop.num = prop.num - us.us_prop_num
		role.user_id = self.user.csv_id
		for k,v in pairs(us) do
			role[k] = v
		end
		role.k_csv_id1 = 0
		role.k_csv_id2 = 0
		role.k_csv_id3 = 0
		role.k_csv_id4 = 0
		role.k_csv_id5 = 0
		role.k_csv_id6 = 0
		role.k_csv_id7 = 0
		if self.user.ifxilian == 1 then
			local n, r = self.xilian(role, {role_id=role.csv_id, is_locked1=false, is_locked2=false, is_locked3=false, is_locked4=false, is_locked5=false})
			assert(n == 0, string.format("%d locked.", n))
			role.property_id1 = r.property_id1
			role.value1 = r.value1
			role.property_id2 = r.property_id2
			role.value2 = r.value2
			role.property_id3 = r.property_id3
			role.value3 = r.value3
			role.property_id4 = r.property_id4
			role.value4 = r.value4
			role.property_id5 = r.property_id5
			role.value5 = r.value5
		else
			role.property_id1 = 0
			role.value1 = 0
			role.property_id2 = 0
			role.value2 = 0
			role.property_id3 = 0
			role.value3 = 0
			role.property_id4 = 0
			role.value4 = 0
			role.property_id5 = 0
			role.value5 = 0
		end
		role = self.user.u_rolemgr.create(role)
		self.user.u_rolemgr:add(role)
		role:__insert_db(const.DB_PRIORITY_2)
	end
end

function cls:create_default(uid)
	-- body
	local factory = self._myfactory
	local user = factory:create_user(uid)
	return user
end

function cls:signup(uid)
	-- body
	print("**********************************", uid)
	local u =  self:create_default(uid)
	u:update_wait()

	local cls
	cls = require "models/u_achievementmgr"
	u.u_achievementmgr = cls.new()
	cls = require "models/u_achievement_rcmgr"
	u.u_achievement_rcmgr = cls.new()
	cls = require "models/u_ara_batmgr"
	u.u_ara_batmgr = cls.new()
	cls = require "models/u_ara_rnk_rwdmgr"
	u.u_ara_rnk_rwdmgr = cls.new()
	cls = require "models/u_cgoldmgr"
	u.u_cgoldmgr = cls.new()
	cls = require "models/u_checkinmgr"
	u.u_checkinmgr = cls.new()
	cls = require "models/u_checkin_monthmgr"
	u.u_checkin_monthmgr = cls.new()
	cls = require "models/u_checkpointmgr"
	u.u_checkpointmgr = cls.new()
	cls = require "models/u_checkpoint_rcmgr"
	u.u_checkpoint_rcmgr = cls.new()
	cls = require "models/u_ara_batmgr"
	u.u_ara_batmgr  = cls.new()
	cls = require "models/u_ara_rnk_rwdmgr"
	u.u_ara_rnk_rwdmgr = cls.new()
	cls = require "models/u_cgoldmgr"
	u.u_cgoldmgr = cls.new()
	cls = require "models/u_checkinmgr"
	u.u_checkinmgr = cls.new()
	cls = require "models/u_checkin_monthmgr"
	u.u_checkin_monthmgr = cls.new()
	cls = require "models/u_checkpointmgr"
	u.u_checkpointmgr = cls.new()
	cls = require "models/u_checkpoint_rcmgr"
	u.u_checkpoint_rcmgr = cls.new()
	cls = require "models/u_equipmentmgr"
	u.u_equipmentmgr = cls.new()
	cls = require "models/u_exercisemgr"
	u.u_exercisemgr = cls.new()
	-- u.u_friendmgr = u_friendmgr
	-- u.u_friendmsgmgr = u_friendmsgmgr
	cls = require "models/u_goodsmgr"
	u.u_goodsmgr = cls.new()
	cls = require "models/u_journalmgr"
	u.u_journalmgr = cls.new()
	cls = require "models/u_kungfumgr"
	u.u_kungfumgr = cls.new()
	cls = require "models/u_lilian_mainmgr"
	u.u_lilian_mainmgr = cls.new()
	cls = require "models/u_lilian_phy_powermgr"
	u.u_lilian_phy_powermgr = cls.new()
	cls = require "models/u_lilian_qg_nummgr"
	u.u_lilian_qg_nummgr = cls.new()
	cls = require "models/u_lilian_submgr"
	u.u_lilian_submgr = cls.new()
	cls = require "models/u_new_drawmgr"
	u.u_drawmgr = cls.new()
	-- u.u_new_emailmgr = u_new_emailmgr 
	cls = require "models/u_propmgr"
	u.u_propmgr = cls.new()
	cls = require "models/u_purchase_goodsmgr"
	u.u_purchase_goodsmgr = cls.new()
	cls = require "models/u_purchase_rewardmgr"
	u.u_purchase_rewardmgr = cls.new()
	cls = require "models/u_recharge_recordmgr"
	u.u_recharge_recordmgr = cls.new()
	cls = require "models/u_recharge_vip_rewardmgr"
	u.u_recharge_vip_rewardmgr = cls.new()
	cls = require "models/u_rolemgr"
	u.u_rolemgr = cls.new()

	local r = skynet.call(".game", "lua", "query_g_equipment")
	for k,v in pairs(r) do
		local equip = skynet.call(".game", "lua", "query_g_equipment_enhance", v.csv_id*1000+v.level)
		equip.user_id = u.csv_id
		equip.id = genpk_2(equip.user_id, equip.csv_id)
		equip = u.u_equipmentmgr:create_entity(equip)
		u.u_equipmentmgr:add(equip)
	end
	u.u_equipmentmgr:update_wait()

	local prop = skynet.call(".game", "lua", "query_g_prop", const.GOLD)
	prop.user_id = u.csv_id
	prop.num = 100
	prop.id = genpk_2(prop.user_id, prop.csv_id)
	prop = u.u_propmgr:create_entity(prop)
	u.u_propmgr:add(prop)

	prop = skynet.call(".game", "lua", "query_g_prop", const.DIAMOND)
	prop.user_id = u.csv_id
	prop.num = 100
	prop.id = genpk_2(prop.user_id, prop.csv_id)
	prop = u.u_propmgr:create_entity(prop)
	u.u_propmgr:add(prop)

	prop = skynet.call(".game", "lua", "query_g_prop", const.EXP)
	prop.user_id = u.csv_id
	prop.num = 100
	prop.id = genpk_2(prop.user_id, prop.csv_id)
	prop = u.u_propmgr:create_entity(prop)
	u.u_propmgr:add(prop)
	
	prop = skynet.call(".game", "lua", "query_g_prop", const.LOVE)
	prop.user_id = u.csv_id
	prop.num = 100     
	prop.id = genpk_2(prop.user_id, prop.csv_id)
	prop = u.u_propmgr:create_entity(prop)
	u.u_propmgr:add(prop)
	
	--add invitation
	prop = skynet.call(".game", "lua" , "query_g_prop" , 50007)
	assert( prop )
	prop.user_id = u.csv_id
	prop.num = 100
	prop.id = genpk_2(prop.user_id, prop.csv_id)
	prop = u.u_propmgr:create_entity(prop)
	u.u_propmgr:add(prop)
	u.u_propmgr:update_wait()

	-- local newemail = { 
	-- 				   type = 1 , title = "new user email" , 
	-- 				   content = "Welcome to the game" , 
	-- 				   itemsn1 = 1 , itemnum1 = 10000 , 
	-- 				   itemsn2 = 2 , itemnum2 = 10000 , 
	-- 				   itemsn3 = 3 , itemnum3 = 10000
	-- 				}  
	-- skynet.send(".channel", "lua", "send_email_to_group", newemail,  { { uid = u.csv_id } })

	for i=1,8 do
		local csv_id = i * 1000 + 1
		local a = skynet.call(".game", "lua", "query_g_achievement", csv_id)
		a.user_id = u.csv_id
		a.finished = 0
		a.reward_collected = 0
		a.is_unlock = 1
		a.is_valid = 1
		a.id = genpk_2(a.user_id, a.csv_id)
		a = u.u_achievementmgr:create_entity(a)	
		u.u_achievementmgr:add(a)
	end
	
	u.u_achievementmgr:update_wait()

	local r = skynet.call(".game", "lua", "query_g_goods")
	for k,v in pairs(r) do
		local t = { user_id = u.csv_id, csv_id=v.csv_id, inventory=v.inventory_init, countdown=0, st=0}
		t.id = genpk_2(t.user_id, t.csv_id)
		local a = u.u_goodsmgr:create_entity(t)
		u.u_goodsmgr:add(a)
	end
	u.u_goodsmgr:update_wait()

	local tmp = {
		user_id = u.csv_id,
		chapter = u.cp_chapter,
		chapter_type0 = 1,       
		chapter_type1 = 0,
		chapter_type2 = 0,
	}
	tmp.id = genpk_2(tmp.user_id, tmp.chapter)
	local cp = u.u_checkpointmgr:create_entity(tmp)
	u.u_checkpointmgr:add(cp)
	cp:update_wait()

	local role = skynet.call(self._game, "lua", "query_g_role", 1)
	local role_star = skynet.call(self._game, "lua", "query_g_role_star", role.csv_id*1000+role.star)
	for k,v in pairs(role_star) do
		role[k] = role_star[k]
	end
	role.user_id = assert(u.csv_id)
	role.k_csv_id1 = 0
	role.k_csv_id2 = 0
	role.k_csv_id3 = 0
	role.k_csv_id4 = 0
	role.k_csv_id5 = 0
	role.k_csv_id6 = 0
	role.k_csv_id7 = 0
	local n, r = self:xilian(role, {role_id=role.csv_id, is_locked1=false, is_locked2=false, is_locked3=false, is_locked4=false, is_locked5=false})
	assert(n == 0, string.format("%d locked.", n))
	role.property_id1 = r.property_id1
	role.value1 = r.value1
	role.property_id2 = r.property_id2
	role.value2 = r.value2
	role.property_id3 = r.property_id3
	role.value3 = r.value3
	role.property_id4 = r.property_id4
	role.value4 = r.value4
	role.property_id5 = r.property_id5
	role.value5 = r.value5
	role.id = genpk_2(role.user_id, role.csv_id)
	role = u.u_rolemgr:create_entity(role)
	u.u_rolemgr:add(role)
	print("role:update_wait is called**********************")
	role:update_wait()
	return u
end

function cls:ara_rfh( ... )
	-- body
	local l = {}
	local u = ctx:get_user()
	local leaderboards_name = skynet.getenv("leaderboards_name")
	local r1 = skynet.call(leaderboards_name, "lua", "ranking_range", 1, 10)
	local r2 = skynet.call(leaderboards_name, "lua", "nearby", u:get_csv_id())
	for i,v in ipairs(r1) do
		local r = {}
		r["csv_id"] = v.uid
		r["ara_rnk"] = v.ranking
		if dc.get(v.uid, "online") then
			local addr = dc.get(id, "addr")
			local u = skynet.call(addr, "lua", "user")
			r["total_combat"] = u.total_combat
			r["uname"] = u.uname
			table.insert(l, v)
		else
			local usersmgr = ctx:get_usersmgr()
			usersmgr:load_cache(v.uid)
			local enemy = usersmgr:get(v.uid)
			r["total_combat"] = 10
			r["uname"] = enemy:get(v.uid)
			table.insert(l, v)
		end
	end

	for i,v in ipairs(r2) do
		local r = {}
		r["csv_id"] = v.uid
		r["ara_rnk"] = v.ranking
		if dc.get(v.uid, "online") then
			local addr = dc.get(id, "addr")
			local u = skynet.call(addr, "lua", "user")
			r["total_combat"] = u.total_combat
			r["uname"] = u.uname
			table.insert(l, v)
		else
			local usersmgr = ctx:get_usersmgr()
			usersmgr:load_cache(v.uid)
			local enemy = usersmgr:get(v.uid)
			r["total_combat"] = 10
			r["uname"] = enemy:get(v.uid)
			table.insert(l, v)
		end
	end
	return l
end

function cls:ara_bat_clg(enemy_id, ... )
	-- body
	local modelmgr = self._modelmgr
	local u = self._user
	local ara_fighting = u:get_ara_fighting()
	if ara_fighting == 1 then
		self:ara_bat_ovr(-1)
		u:set_ara_fighting(0)
		return false
	end

	
	local tmp = dc.get(self.user_id)
	if tmp then
		-- this node
		local addr = tmp.addr
		local r = skynet.call(addr, "lua", "ara_info")
		local enemy = ctx.usersmgr.create(r)
		-- local u_rolemgr = 
	end
	u:set_ara_fighting(1)
	return true
end

function cls:ara_bat_ovr(win, ... )
	-- body
	local modelmgr = self._modelmgr
	local u = self._user
	if win == 1 then
		local ara_win_tms = u:get_ara_win_tms()
		ara_win_tms = ara_win_tms + 1
		u:set_ara_win_tms(ara_win_tms)
		local ara_integral = u:get_ara_integral()
		ara_integral = ara_integral + 2
		u:set_ara_integral(ara_integral)

		local arena = self:get_arena()
		local me = arena:get_me()
		local enemy = arena:get_enemy()
		local leaderboards_name = skynet.getenv("leaderboards_name")
		local l = skynet.call(leaderboards_name, "lua", "swap", me:get_field("csv_id"), enemy:get_field("csv_id"))
	elseif win == 0 then
		local ara_tie_tms = u:get_ara_tie_tms()
		ara_tie_tms = ara_tie_tms + 1
		u:set_ara_tie_tms(ara_tie_tms)
		local ara_integral = u:get_ara_integral()
		ara_integral = ara_integral + 2
		u:set_ara_integral(ara_integral)
	elseif win == -1 then
		local ara_lose_tms = u:get_ara_lose_tms()
		ara_lose_tms = ara_lose_tms + 1
		u:set_ara_lose_tms(ara_lose_tms)
		ara_integral = ara_integral + 1
		u:set_ara_integral(ara_integral)
	end
	u:set_ara_fighting(0)
	local now = os.time()
	local users_ara_batmgr = modelmgr:get_users_ara_batmgr()
	-- local bat = users_ara_batmgr:get(self._userid)
	-- bat:set_over(1)
	-- bat:set_res(win)
	-- bat:update_db()
end

return cls
