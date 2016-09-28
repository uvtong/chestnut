local skynet = require "skynet"
local util = require "util"
local query = require "query"
local const = require "const"

local cls = class("load_user")

function cls:ctor(env, ... )
	-- body
	self._env = env
	self._data = {}
end

function cls:signup(uid)
	-- body
	
	local cls
	cls = require "models/usersmgr"
	local usersmgr = cls.new()
	self._data["usersmgr"] = usersmgr
	self._env:set_usersmgr(usersmgr)

	local factory = self._env:get_myfactory()
	local u = factory:create_user(uid)
	u:update_wait()
	self._data["user"] = u
	self._env:set_user(u)

	cls = require "models/u_achievementmgr"
	u.u_achievementmgr = cls.new()
	self._data["u_achievementmgr"] = u.u_achievementmgr
	cls = require "models/u_achievement_rcmgr"
	u.u_achievement_rcmgr = cls.new()
	self._data["u_achievement_rcmgr"] = u.u_achievement_rcmgr
	self._data["u_achievement_rcmgr"]:set_user(u)
	cls = require "models/u_ara_batmgr"
	u.u_ara_batmgr = cls.new()
	self._data["u_ara_batmgr"] = u.u_ara_batmgr
	self._data["u_ara_batmgr"]:set_user(u)
	cls = require "models/u_ara_rnk_rwdmgr"
	u.u_ara_rnk_rwdmgr = cls.new()
	self._data["u_ara_rnk_rwdmgr"] = u.u_ara_rnk_rwdmgr
	self._data["u_ara_rnk_rwdmgr"]:set_user(u)
	cls = require "models/u_cgoldmgr"
	u.u_cgoldmgr = cls.new()
	self._data["u_cgoldmgr"] = u.u_cgoldmgr
	self._data["u_cgoldmgr"]:set_user(u)
	cls = require "models/u_checkinmgr"
	u.u_checkinmgr = cls.new()
	self._data["u_checkinmgr"] = u.u_checkinmgr
	self._data["u_checkinmgr"]:set_user(u)
	cls = require "models/u_checkin_monthmgr"
	u.u_checkin_monthmgr = cls.new()
	self._data["u_checkin_monthmgr"] = u.u_checkin_monthmgr
	self._data["u_checkin_monthmgr"]:set_user(u)
	cls = require "models/u_checkpointmgr"
	u.u_checkpointmgr = cls.new()
	self._data["u_checkpointmgr"] = u.u_checkpointmgr
	self._data["u_checkpointmgr"]:set_user(u)
	cls = require "models/u_checkpoint_rcmgr"
	u.u_checkpoint_rcmgr = cls.new()
	self._data["u_checkpoint_rcmgr"] = u.u_checkpoint_rcmgr
	self._data["u_checkpoint_rcmgr"]:set_user(u)
	cls = require "models/u_ara_batmgr"
	u.u_ara_batmgr  = cls.new()
	self._data["u_ara_batmgr"] = u.u_ara_batmgr
	self._data["u_ara_batmgr"]:set_user(u)
	cls = require "models/u_ara_rnk_rwdmgr"
	u.u_ara_rnk_rwdmgr = cls.new()
	self._data["u_ara_rnk_rwdmgr"] = u.u_ara_rnk_rwdmgr
	self._data["u_ara_rnk_rwdmgr"]:set_user(u)
	cls = require "models/u_cgoldmgr"
	u.u_cgoldmgr = cls.new()
	self._data["u_cgoldmgr"] = u.u_cgoldmgr
	self._data["u_cgoldmgr"]:set_user(u)
	cls = require "models/u_checkinmgr"
	u.u_checkinmgr = cls.new()
	self._data["u_checkinmgr"] = u.u_checkinmgr
	self._data["u_checkinmgr"]:set_user(u)
	cls = require "models/u_checkin_monthmgr"
	u.u_checkin_monthmgr = cls.new()
	self._data["u_checkin_monthmgr"] = u.u_checkin_monthmgr
	self._data["u_checkin_monthmgr"]:set_user(u)
	cls = require "models/u_checkpointmgr"
	u.u_checkpointmgr = cls.new()
	self._data["u_checkpointmgr"] = u.u_checkpointmgr
	self._data["u_checkpointmgr"]:set_user(u)
	cls = require "models/u_checkpoint_rcmgr"
	u.u_checkpoint_rcmgr = cls.new()
	self._data["u_checkpoint_rcmgr"] = u.u_checkpoint_rcmgr
	self._data["u_checkpoint_rcmgr"]:set_user(u)
	cls = require "models/u_equipmentmgr"
	u.u_equipmentmgr = cls.new()
	self._data["u_equipmentmgr"] = u.u_equipmentmgr
	self._data["u_equipmentmgr"]:set_user(u)
	cls = require "models/u_exercisemgr"
	u.u_exercisemgr = cls.new()
	self._data["u_exercisemgr"] = u.u_exercisemgr
	self._data["u_exercisemgr"]:set_user(u)
	-- u.u_friendmgr = u_friendmgr
	-- u.u_friendmsgmgr = u_friendmsgmgr
	cls = require "models/u_goodsmgr"
	u.u_goodsmgr = cls.new()
	self._data["u_goodsmgr"] = u.u_goodsmgr
	self._data["u_goodsmgr"]:set_user(u)
	cls = require "models/u_journalmgr"
	u.u_journalmgr = cls.new()
	self._data["u_journalmgr"] = u.u_journalmgr
	self._data["u_journalmgr"]:set_user(u)
	cls = require "models/u_kungfumgr"
	u.u_kungfumgr = cls.new()
	self._data["u_kungfumgr"] = u.u_kungfumgr
	self._data["u_kungfumgr"]:set_user(u)
	cls = require "models/u_lilian_mainmgr"
	u.u_lilian_mainmgr = cls.new()
	self._data["u_lilian_mainmgr"] = u.u_lilian_mainmgr
	self._data["u_lilian_mainmgr"]:set_user(u)
	cls = require "models/u_lilian_phy_powermgr"
	u.u_lilian_phy_powermgr = cls.new()
	self._data["u_lilian_phy_powermgr"] = u.u_lilian_phy_powermgr
	self._data["u_lilian_phy_powermgr"]:set_user(u)
	cls = require "models/u_lilian_qg_nummgr"
	u.u_lilian_qg_nummgr = cls.new()
	self._data["u_lilian_qg_nummgr"] = u.u_lilian_qg_nummgr
	cls = require "models/u_lilian_submgr"
	u.u_lilian_submgr = cls.new()
	self._data["u_lilian_submgr"] = u.u_lilian_submgr
	self._data["u_lilian_submgr"]:set_user(u)
	cls = require "models/u_new_drawmgr"
	u.u_drawmgr = cls.new()
	self._data["u_drawmgr"] = u.u_drawmgr
	self._data["u_drawmgr"]:set_user(u)
	cls = require "models/u_new_emailmgr"
	local u_new_emailmgr = cls.new()
	u_new_emailmgr:set_user(u)
	u.u_new_emailmgr = u_new_emailmgr 
	self._data["u_new_emailmgr"] = u_new_emailmgr
	cls = require "models/u_propmgr"
	u.u_propmgr = cls.new()
	self._data["u_propmgr"] = u.u_propmgr
	self._data["u_propmgr"]:set_user(u)
	cls = require "models/u_purchase_goodsmgr"
	u.u_purchase_goodsmgr = cls.new()
	self._data["u_purchase_goodsmgr"] = u.u_purchase_goodsmgr
	self._data["u_purchase_goodsmgr"]:set_user(u)
	cls = require "models/u_purchase_rewardmgr"
	u.u_purchase_rewardmgr = cls.new()
	self._data["u_purchase_rewardmgr"] = u.u_purchase_rewardmgr
	self._data["u_purchase_rewardmgr"]:set_user(u)
	cls = require "models/u_recharge_recordmgr"
	u.u_recharge_recordmgr = cls.new()
	self._data["u_recharge_recordmgr"] = u.u_recharge_recordmgr
	self._data["u_recharge_recordmgr"]:set_user(u)
	cls = require "models/u_recharge_vip_rewardmgr"
	u.u_recharge_vip_rewardmgr = cls.new()
	self._data["u_recharge_vip_rewardmgr"] = u.u_recharge_vip_rewardmgr
	self._data["u_recharge_vip_rewardmgr"]:set_user(u)
	cls = require "models/u_rolemgr"
	local u_rolemgr = cls.new()
	u_rolemgr:set_user(u)
	u.u_rolemgr = u_rolemgr
	self._data["u_rolemgr"] = u_rolemgr
	cls = require "models/u_ara_worshipmgr"
	local u_ara_worshipmgr = cls.new()
	u_ara_worshipmgr:set_user(u)
	self._data["u_ara_worshipmgr"] = u_ara_worshipmgr
	cls = require "models/u_ara_worship_rcmgr"
	local u_ara_worship_rcmgr = cls.new()
	u_ara_worship_rcmgr:set_user(u)
	self._data["u_ara_worship_rcmgr"] = u_ara_worship_rcmgr
	cls = require "models/u_ara_ptsmgr"
	local u_ara_ptsmgr = cls.new()
	u_ara_ptsmgr:set_user(u)
	self._data["u_ara_ptsmgr"] = u_ara_ptsmgr
	local u_ara_rnk_rwdmgr = cls.new()
	u_ara_rnk_rwdmgr = cls.new()
	u_ara_rnk_rwdmgr:set_user(u)
	self._data["u_ara_rnk_rwdmgr"] = u_ara_rnk_rwdmgr

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
	prop.num = 100000
	prop.id = genpk_2(prop.user_id, prop.csv_id)
	prop = u.u_propmgr:create_entity(prop)
	u.u_propmgr:add(prop)

	prop = skynet.call(".game", "lua", "query_g_prop", const.DIAMOND)
	prop.user_id = u.csv_id
	prop.num = 100000
	prop.id = genpk_2(prop.user_id, prop.csv_id)
	prop = u.u_propmgr:create_entity(prop)
	u.u_propmgr:add(prop)

	prop = skynet.call(".game", "lua", "query_g_prop", const.EXP)
	prop.user_id = u.csv_id
	prop.num = 100000
	prop.id = genpk_2(prop.user_id, prop.csv_id)
	prop = u.u_propmgr:create_entity(prop)
	u.u_propmgr:add(prop)
	
	prop = skynet.call(".game", "lua", "query_g_prop", const.LOVE)
	prop.user_id = u.csv_id
	prop.num = 100000    
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

	prop = skynet.call(".game", "lua", "query_g_prop", 10001)
	assert(prop)
	prop.user_id = u.csv_id
	prop.num = 100000
	prop.id = genpk_2(prop.user_id, prop.csv_id)
	prop = u.u_propmgr:create_entity(prop)
	u.u_propmgr:add(prop)

	prop = skynet.call(".game", "lua", "query_g_prop", 10002)
	assert(prop)
	prop.user_id = u.csv_id
	prop.num = 100000
	prop.id = genpk_2(prop.user_id, prop.csv_id)
	prop = u.u_propmgr:create_entity(prop)
	u.u_propmgr:add(prop)

	prop = skynet.call(".game", "lua", "query_g_prop", 10003)
	assert(prop)
	prop.user_id = u.csv_id
	prop.num = 100000
	prop.id = genpk_2(prop.user_id, prop.csv_id)
	prop = u.u_propmgr:create_entity(prop)
	u.u_propmgr:add(prop)

	prop = skynet.call(".game", "lua", "query_g_prop", 10004)
	assert(prop)
	prop.user_id = u.csv_id
	prop.num = 100000
	prop.id = genpk_2(prop.user_id, prop.csv_id)
	prop = u.u_propmgr:create_entity(prop)
	u.u_propmgr:add(prop)

	prop = skynet.call(".game", "lua", "query_g_prop", 10005)
	assert(prop)
	prop.user_id = u.csv_id
	prop.num = 100000
	prop.id = genpk_2(prop.user_id, prop.csv_id)
	prop = u.u_propmgr:create_entity(prop)
	u.u_propmgr:add(prop)

	prop = skynet.call(".game", "lua", "query_g_prop", 10006)
	assert(prop)
	prop.user_id = u.csv_id
	prop.num = 100000
	prop.id = genpk_2(prop.user_id, prop.csv_id)
	prop = u.u_propmgr:create_entity(prop)
	u.u_propmgr:add(prop)

	prop = skynet.call(".game", "lua", "query_g_prop", 10007)
	assert(prop)
	prop.user_id = u.csv_id
	prop.num = 100000
	prop.id = genpk_2(prop.user_id, prop.csv_id)
	prop = u.u_propmgr:create_entity(prop)
	u.u_propmgr:add(prop)

	u.u_propmgr:update_wait()


	--add email
	local newemail = {}
	newemail.type = 1
	newemail.title = "new user email"
	newemail.content = "Welcome to the game"
	newemail.itemsn1 = 1 
	newemail.itemnum1 = 100000
	newemail.itemsn2 = 2
	newemail.itemnum2 = 100000
	newemail.itemsn3 = 3
	newemail.itemnum3 = 100000
	newemail.itemsn4 = 3
	newemail.itemnum4 = 100000
	newemail.itemsn5 = 3
	newemail.itemnum5 = 100000
	newemail.acctime = os.time() -- an integer
	newemail.isread = 0
	newemail.isreward = 0
	newemail.isdel = 0
	newemail.deltime = 0
	newemail.uid = u:get_field("csv_id")
	newemail.csv_id = skynet.call(".game", "lua" , "u_guid" , newemail.uid, const.UEMAILENTROPY)
	newemail.id = genpk_2(u:get_field("csv_id"), newemail.csv_id)
	local email = self._data["u_new_emailmgr"]:create_entity(newemail)
	self._data["u_new_emailmgr"]:add(email)
	email:update_db()
	
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

	local role = skynet.call(self._env:get_game(), "lua", "query_g_role", 1)
	local role_star = skynet.call(self._env:get_game(), "lua", "query_g_role_star", role.csv_id*1000+role.star)
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
	local n, r = self._env:xilian(role, {role_id=role.csv_id, is_locked1=false, is_locked2=false, is_locked3=false, is_locked4=false, is_locked5=false})
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
	u:set_field("ara_role_id1", role:get_field("csv_id"))
	
	role:update_wait()

	return u
end

function cls:load1(uid)
	-- body
	cls = require "models/usersmgr"
	local usersmgr = cls.new()
	self._data["usersmgr"] = usersmgr

	self:load_user(uid)
	self:load_u_kungfu()
	self:load_u_prop()
	self:load_u_role()
	self:load_u_equipment()
end

function cls:load(uid)
	-- body
	local cls = require "models/usersmgr"
	local usersmgr = cls.new()
	self._data["usersmgr"] = usersmgr
	self._env:set_usersmgr(usersmgr)

	self:load_user(uid)
	self:load_u_achievement()
	self:load_u_achievement_rc()
	self:load_u_checkin()
	self:load_u_checkin_month()
	self:load_u_checkpoint()
	self:load_u_checkpoint_rc()
	self:load_u_equipment()
	self:load_u_exercise()
	self:load_u_cgold()
	self:load_u_new_email()
	self:load_u_kungfu()
	--self:load_u_draw()
	self:load_u_new_draw()
	self:load_u_prop()
	self:load_u_role()
	self:load_u_purchase_goods()
	self:load_u_purchase_reward(user)
	self:load_u_recharge_count(user)
	self:load_u_recharge_record(user)
	self:load_u_recharge_vip_reward(user)
	self:load_u_journal(user)
	self:load_u_goods(user)
	self:load_u_lilian_main(user)
	self:load_u_lilian_sub(user)
	self:load_u_lilian_qg_num(user)
	self:load_u_lilian_phy_power(user)
	self:load_u_new_friend()
	self:load_u_new_friendmsg()
	self:load_u_ara_worship()
	self:load_u_ara_worship_rc()
	self:load_u_ara_pts()
	self:load_u_ara_rnk_rwd()
	return self:get_user()
end 
	
function cls:load_remote(uid, p )
	-- body
	cls = require "models/usersmgr"
	local usersmgr = cls.new()
	self._data["usersmgr"] = usersmgr
	
	self:load_user_remote(uid, p)
	self:load_u_equipment_remote(p)
	self:load_u_role_remote(p)
	self:load_u_kungfu_remote(p)
end 
	
function cls:gen_remote( ... )
	-- body
	local rm = {}
	self:gen_user_remote(rm)
	self:gen_u_equipment_remote(rm)
	self:gen_u_role_remote(rm)
	self:gen_u_kungfu_remote(rm)
	return rm
end 
	
function cls:load_user_remote(uid, p, ... )
	-- body
	local usersmgr = self:get_usersmgr()
	if usersmgr == nil then
		local cls = require "models/usersmgr"
		local usersmgr = cls.new()
		self._env:set_usersmgr(usersmgr)
	end

	local u = p["user"]
	usersmgr:load_remote({u})
	local user = usersmgr:get(uid)
	self._data["user"] = user
	return user
end

function cls:gen_user_remote(rm, ... )
	-- body
	local u = self._data["user"]
	rm["user"] = u.__fields
end

function cls:load_user(user_id)
	-- body
	local usersmgr = self:get_usersmgr()
	if usersmgr == nil then
		local cls = require "models/usersmgr"
	 	usersmgr = cls.new()
	 	self._data["usersmgr"] = usersmgr
		self._env:set_usersmgr(usersmgr)
	end
	usersmgr:load_db("pk", user_id)
	usersmgr:load_data_to_cache(user_id)
	local user = usersmgr:get(user_id)
	self._data["user"] = user
	self._env:set_user(user)
	return user
end 	       
	
function cls:get_user( ... )
	-- body
	return self._data["user"]
end	       
	
function cls:get_usersmgr( ... )
	-- body
	return self._data["usersmgr"]
end 
	
function cls:load_u_new_friend()
	local u = self:get_user()
	local cls = require "models/u_new_friendmgr"
	local u_new_friendmgr = cls.new()
	u_new_friendmgr:load_db("fk", u:get_csv_id())
	u_new_friendmgr:set_user(u)
	self._data["u_new_friendmgr"] = u_new_friendmgr
	u.u_new_friendmgr = u_new_friendmgr
end              
               
function cls:get_u_new_friendmgr()
	return self._data["u_new_friendmgr"]
end              
               
function cls:load_u_new_friendmsg()
    local u = self:get_user()
	local cls = require "models/u_new_friendmsgmgr"
	local u_new_friendmsgmgr = cls.new()
	u_new_friendmsgmgr:set_user(u)
	local sql = string.format("select * from u_new_friendmsg where (fromid = %d and isread = 0 and type = 1) or (toid = %d and isread = 0 and type = 1)", u:get_csv_id(), u:get_csv_id())
	local r = query.read(".rdb", "u_new_friendmsg", sql)
	assert(r.errno == nil) --if query failed, return errno, badresult, sqlstate, err
	for k, v in ipairs(r) do
       	local a = u_new_friendmsgmgr:create_entity( v )
       	u_new_friendmsgmgr:add( a )		
	end    
	self._data["u_new_friendmsgmgr"] = u_new_friendmsgmgr
	u.u_new_friendmsgmgr = u_new_friendmsgmgr
end     
	
function cls:get_u_new_friendmsgmgr()
	return self._data["u_new_friendmsgmgr"]
end 	
				
function cls:load_u_achievement()
	-- body
	local u = self:get_user()
	local cls = require "models/u_achievementmgr"
	local u_achievementmgr = cls.new()
	u_achievementmgr:load_db("fk", u:get_csv_id())
	u_achievementmgr:set_user(u)
	self._data["u_achievementmgr"] = u_achievementmgr
	u.u_achievementmgr = u_achievementmgr
end 
	
function cls:get_u_achievementmgr( ... )
	-- body
	return self._data["u_achievementmgr"]
end

function cls:load_u_achievement_rc()
	-- body
	local u = self:get_user()
	local cls = require "models/u_achievement_rcmgr"
	local u_achievement_rcmgr = cls.new()
	u_achievement_rcmgr:load_db("fk", u:get_csv_id())
	u_achievement_rcmgr:set_user(u)
	self._data["u_achievement_rcmgr"] = u_achievement_rcmgr
	u.u_achievement_rcmgr = u_achievement_rcmgr
end

function cls:get_u_achievement_rcmgr( ... )
	-- body
	return self._data["u_achievement_rcmgr"]
end

function cls:load_u_checkin()
	-- body
	local u = self:get_user()
	local cls = require "models/u_checkinmgr"
	local u_checkinmgr = cls.new()
	local addr = util.random_db()
	local sql = string.format( "select * from u_checkin where user_id = %d and if_latest = 1", u:get_csv_id())
	local r = query.read(".rdb", "u_checkin", sql)
	for i,v in ipairs( r ) do
		local a = u_checkinmgr:create( v )
		u_checkinmgr:add( a )
	end
	u_checkinmgr:set_user(u)
	self._data['u_checkinmgr'] = u_checkinmgr
	u.u_checkinmgr = u_checkinmgr
end

function cls:get_u_checkinmgr( ... )
	-- body
	return self._data['u_checkinmgr']
end

function cls:load_u_checkin_month()
	-- body
	local u = self:get_user()
	local cls = require "models/u_checkin_monthmgr"
	local u_checkin_monthmgr = cls.new()

	local sql = string.format("select * from u_checkin_month where user_id = %d", u:get_csv_id())
	local r = query.read(".rdb", "u_checkin_month", sql)
	assert(r.errno == nil)

	for k, v in ipairs(r) do
		local a = u_checkin_monthmgr:create(v)
		u_checkin_monthmgr:add(a)
	end
	
	u_checkin_monthmgr:set_user(u)
	self._data["u_checkin_monthmgr"] = u_checkin_monthmgr
	u.u_checkin_monthmgr = u_checkin_monthmgr
end

function cls:get_u_checkin_monthmgr( ... )
	-- body
	return self._data["u_checkin_monthmgr"]
end

function cls:load_u_exercise()
	local u = self:get_user()
	local cls = require "models/u_exercisemgr"
	local u_exercise_mgr = cls.new()
	local sql = string.format( "select * from u_exercise where exercise_time = ( select exercise_time from u_exercise where user_id = %s ORDER BY exercise_time DESC limit 1 )" , u:get_csv_id())
	local r = query.read(".rdb", "u_exercise", sql)
	-- local r = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
	for i , v in ipairs( r ) do
		local a = u_exercise_mgr:create( v )
		u_exercise_mgr:add( a )
	end
	u_exercise_mgr:set_user(u)
	self._data["u_exercise_mgr"] = u_exercise_mgr
	u.u_exercise_mgr = u_exercise_mgr
end

function cls:get_u_exercisemgr( ... )
	-- body
	return self._data["u_exercise_mgr"]
end

function cls:load_u_cgold()
	local u = self:get_user()
	local cls = require "models/u_cgoldmgr"
	local u_cgoldmgr = cls.new()
	local sql = string.format( "select * from u_cgold where cgold_time = ( select cgold_time from u_cgold where user_id = %s ORDER BY cgold_time DESC limit 1 )" , u:get_csv_id())
	local r = query.read(".rdb", "u_cgold", sql)
	-- local r = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
	for i , v in ipairs( r ) do
		local a = u_cgoldmgr:create( v )
		u_cgoldmgr:add( a )
	end
	u_cgoldmgr:set_user(u)
	self._data["u_cgoldmgr"] = u_cgoldmgr
	u.u_cgoldmgr = u_cgoldmgr
end

function cls:get_u_cgoldmgr( ... )
	-- body
	return self._data["u_cgoldmgr"]
end

function cls:load_u_checkpoint()
	-- body
	local u = self:get_user()
	local cls = require "models/u_checkpointmgr"
	local u_checkpointmgr = cls.new()
	u_checkpointmgr:load_db("fk", u:get_csv_id())
	u_checkpointmgr:set_user(u)
	self._data["u_checkpointmgr"] = u_checkpointmgr
	u.u_checkpointmgr = u_checkpointmgr
end

function cls:get_u_checkpointmgr( ... )
	-- body
	return self._data["u_checkpointmgr"]
end

function cls:load_u_checkpoint_rc()
	-- body
	local u = self:get_user()
	local cls = require "models/u_checkpoint_rcmgr"
	local u_checkpoint_rcmgr = cls.new()
	u_checkpoint_rcmgr:load_db("fk", u:get_csv_id())
	u_checkpoint_rcmgr:set_user(u)
	self._data["u_checkpoint_rcmgr"] = u_checkpoint_rcmgr
	u.u_checkpoint_rcmgr = u_checkpoint_rcmgr
end

function cls:get_u_checkpoint_rcmgr( ... )
	-- body
	return self._data["u_checkpoint_rcmgr"]
end

function cls:load_u_equipment_remote(p, ... )
	-- body
	local u = self:get_user()
	local cls = require "models/u_equipmentmgr"
	local u_equipmentmgr = cls.new()
	u_equipmentmgr:load_remote(p[u_equipmentmgr.__tname])
	u_equipmentmgr:set_user(u)
	self._data[u_equipmentmgr.__tname.."mgr"] = u_equipmentmgr
	u.u_equipmentmgr = u_equipmentmgr
end

function cls:gen_u_equipment_remote(rm, ... )
	-- body
	local r = {}
	local u_equipmentmgr = self:get_u_equipmentmgr()
	for k,v in pairs(u_equipmentmgr.__data) do
		table.insert(r, v.__fields)
	end
	rm[u_equipmentmgr.__tname] = r
end

function cls:load_u_equipment()
	-- body
	local u = self:get_user()
	local cls = require "models/u_equipmentmgr"
	local u_equipmentmgr = cls.new()
	u_equipmentmgr:load_db("fk", u:get_csv_id())
	u_equipmentmgr:load_data_to_cache()
	u_equipmentmgr:set_user(u)
	self._data["u_equipmentmgr"] = u_equipmentmgr
	u.u_equipmentmgr = u_equipmentmgr
end 

function cls:get_u_equipmentmgr( ... )
	-- body
	return self._data["u_equipmentmgr"]
end

function cls:load_u_kungfu_remote(p, ... )
	-- body
	local u = self:get_user()
	local cls = require "models/u_kungfumgr"
	local u_kungfumgr = cls.new()
	u_kungfumgr:set_user(u)
	u_kungfumgr:load_remote(p[u_kungfumgr.__tname])
	self._data["u_kungfumgr"] = u_kungfumgr
	u.u_kungfumgr = u_kungfumgr
end

function cls:gen_u_kungfu_remote(rm, ... )
	-- body
	local r = {}
	local u_kungfumgr = self:get_u_kungfumgr()
	for k,v in pairs(u_kungfumgr.__data) do
		table.insert(r, v.__fields)
	end
	rm[u_kungfumgr.__tname] = r
end

function cls:load_u_kungfu()
	-- body
	local u = self:get_user()
	local cls = require "models/u_kungfumgr"
	local u_kungfumgr = cls.new()
	u_kungfumgr:set_user(u)
	u_kungfumgr:load_db("fk", u:get_csv_id())
	u_kungfumgr:load_data_to_cache()
	u_kungfumgr:set_user(u)
	self._data["u_kungfumgr"] = u_kungfumgr
	u.u_kungfumgr = u_kungfumgr
end 
	
function cls:get_u_kungfumgr( ... )
 	-- body
 	return self._data["u_kungfumgr"]
end 
	
function cls:load_u_new_draw()
	local u = self:get_user()
	local cls = require "models/u_new_drawmgr"
	local u_drawmgr = cls.new()
	u_drawmgr:set_user(user)
	local sql1 = string.format("select * from u_new_draw where uid = %d and is_latest = 1", u:get_csv_id())
	--local sql1 = string.format( "select * from u_new_draw where srecvtime = ( select srecvtime from u_new_draw where uid = %s and drawtype = 1 ORDER BY srecvtime DESC limit 1 )" , u:get_csv_id())
	local r = query.read(".rdb", "u_new_draw", sql1)
	for i , v in ipairs( r ) do
		--print( " has number" )
		local draw = u_drawmgr:create( v )
		assert( draw )
		u_drawmgr:add( draw )
	end
	
	-- local sql2 = string.format( "select * from u_new_draw where srecvtime = ( select srecvtime from u_new_draw where uid = %s and drawtype = 2 ORDER BY srecvtime DESC limit 1 )" , u:get_csv_id())
	-- -- local t = skynet.call( util.random_db() , "lua" , "command" , "query" , sql2 )
	-- local t = query.read(".rdb", "u_new_draw", sql2)
	-- for i , v in ipairs(t) do
	-- 	--print( " has number" )
	-- 	local draw = u_drawmgr:create(v)
	-- 	assert(draw)
	-- 	u_drawmgr:add(draw)
	-- end 
	-- u_drawmgr:set_user(u)
	self._data["u_drawmgr"] = u_drawmgr
	u.u_drawmgr = u_drawmgr
end	
	
function cls:get_u_drawmgr( ... )
	-- body
	return self._data["u_drawmgr"]
end 
	
function cls:load_u_new_email()
	local u = self:get_user()
	assert(u)
	local cls = require "models/u_new_emailmgr"
	local u_new_emailmgr = cls.new()
	assert(u_new_emailmgr)
	u_new_emailmgr:set_user(user)

	print("uid is ", u:get_csv_id())
	local sql = string.format("select * from u_new_email where uid = %d and isdel = 0", u:get_csv_id())
	print(sql)
	local r = query.read(".rdb", "u_new_email", sql)
	assert(r.errno == nil)

	for k, v in ipairs(r) do
		local e = u_new_emailmgr:create_entity(v)
		assert(e)
		u_new_emailmgr:add(e)
	end

	u_new_emailmgr:set_user(u)
	self._data["u_new_emailmgr"] = u_new_emailmgr
	u.u_new_emailmgr = u_new_emailmgr

	-- user.u_emailmgr = u_emailmgr()
    	
	-- --local r = skynet.call( util.random_db() , "lua", "command" , "select" , "u_new_email", { { uid = user.csv_id , isdel = 0 } } )
	-- local sql = string.format("select * from u_new_email where uid = user.csv_id and isdel = 0;")
	-- local r = query.read(".rdb", "u_new_email", sql)
	-- assert(r.errno == nil)

	-- for i , v in ipairs( r ) do
	-- 	local a = user.u_emailmgr:create( v )
	-- 	user.u_emailmgr:add( a )
	-- end
	-- print( "u_emailmgr:get_count" , u_emailmgr:get_count() )
	-- if user.u_emailmgr:get_count() > user.u_emailmgr.__MAXEMAILNUM then
	-- 	print( "sysdelemail is called *********************************************" , u_emailmgr:get_count() )
	-- 	user.u_emailmgr:sysdelemail()
	-- end
	-- u_emailmgr.__user_id = user.csv_id
	-- self._data["u_emailmgr"] = u_emailmgr
end 
   
function cls:get_u_new_emailmgr( ... )
	return self._data["u_new_emailmgr"]
end    

function cls:load_u_lilian_main()
	local u = self:get_user()
	local cls = require "models/u_lilian_mainmgr"
	local u_lilian_mainmgr = cls.new()
	u_lilian_mainmgr:set_user(user)
	-- u_lilian_mainmgr:load_db({ user_id = u:get_csv_id(), iffinished = 0 })
	local sql = string.format("select * from u_lilian_main where `iffinished` = 0 and `user_id` = %d", u:get_field("csv_id"))
	local r = query.read(".rdb", "u_lilian_main", sql)
	for k,v in pairs(r) do
		local entity = u_lilian_mainmgr:create_entity(v)
		u_lilian_mainmgr:add(entity)
	end
	u_lilian_mainmgr:set_user(u)
	self._data["u_lilian_mainmgr"] = u_lilian_mainmgr
	u.u_lilian_mainmgr = u_lilian_mainmgr
end 	
		
function cls:get_u_lilian_mainmgr( ... )
	-- body
	return self._data["u_lilian_mainmgr"]
end 	
	   	
function cls:load_u_lilian_sub(user)
	local u = self:get_user()
	local cls = require "models/u_lilian_submgr"
	local u_lilian_submgr = cls.new()
	u_lilian_submgr:set_user(user)
	u_lilian_submgr:load_db("fk", u:get_field("csv_id"))
	u_lilian_submgr:set_user(u)
	self._data["u_lilian_submgr"] = u_lilian_submgr
	u.u_lilian_submgr = u_lilian_submgr
end 	
    	
function cls:get_u_lilian_submgr( ... )
	-- body
	return self._data["u_lilian_submgr"]
end

function cls:load_u_lilian_qg_num()
	local u = self:get_user()
	local cls = require "models/u_lilian_qg_nummgr"
	local u_lilian_qg_nummgr = cls.new()
	u_lilian_qg_nummgr:set_user(u)
	local date = os.time()
	local sql = string.format( "select * from u_lilian_qg_num where user_id = %d and start_time < %d and %d < end_time" , u:get_csv_id(), date , date)
	-- local nr = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
	local nr = query.read(u_lilian_qg_nummgr.__rdb, "u_lilian_qg_num", sql)
	for i , v in ipairs( nr ) do
		local a = u_lilian_qg_nummgr:create( v )
		u_lilian_qg_nummgr:add( a )
	end
	u_lilian_qg_nummgr:set_user(u)
	self._data["u_lilian_qg_nummgr"] = u_lilian_qg_nummgr
	u.u_lilian_qg_nummgr = u_lilian_qg_nummgr
end 
	
function cls:get_u_lilian_qg_nummgr( ... )
	-- body
	return self._data["u_lilian_qg_nummgr"]
end 
	
function cls:load_u_lilian_phy_power()
	local u = self:get_user()
	local cls = require "models/u_lilian_phy_powermgr"
	local u_lilian_phy_powermgr = cls.new()
	u_lilian_phy_powermgr:set_user(u)
	local date = os.time()
	local sql = string.format( "select * from u_lilian_phy_power where user_id = %d and start_time < %d and %d < end_time", u:get_csv_id(), date , date)
	-- local nr = skynet.call( util.random_db() , "lua" , "command" , "query" , sql )
	local nr = query.read(u_lilian_phy_powermgr.__rdb, "u_lilian_phy_power", sql)
	for i , v in ipairs( nr ) do
		local a = u_lilian_phy_powermgr:create( v )
		u_lilian_phy_powermgr:add( a )
	end
	
	u_lilian_phy_powermgr:set_user(u)
	self._data["u_lilian_phy_powermgr"] = u_lilian_phy_powermgr
	u.u_lilian_phy_powermgr = u_lilian_phy_powermgr
end 

function cls:get_u_lilian_phy_powermgr( ... )
		-- body
	return self._data["u_lilian_phy_powermgr"]
end	

function cls:load_u_prop()
	-- body
	local u = self:get_user()
	local cls = require "models/u_propmgr"
	local u_propmgr = cls.new()
	u_propmgr:set_user(u)
	u_propmgr:load_db("fk", u:get_field("csv_id"))
	u_propmgr:set_user(u)
	self._data["u_propmgr"] = u_propmgr
	u.u_propmgr = u_propmgr
end

function cls:get_u_propmgr( ... )
	-- body
	return self._data["u_propmgr"]
end

function cls:load_u_purchase_goods(user)
	-- body
	local u = self:get_user()
	local cls = require "models/u_purchase_goodsmgr"
	local u_purchase_goodsmgr = cls.new()
	u_purchase_goodsmgr:set_user(user)
	u_purchase_goodsmgr:load_db("fk", u:get_csv_id())
	u_purchase_goodsmgr:set_user(u)
	self._data["u_purchase_goodsmgr"] = u_purchase_goodsmgr
	u.u_purchase_goodsmgr = u_purchase_goodsmgr
end

function cls:get_u_purchase_goodsmgr( ... )
	-- body
	return self._data["u_purchase_goodsmgr"]
end

function cls:load_u_purchase_reward()
	-- body
	local u = self:get_user()
	local cls = require "models/u_purchase_rewardmgr"
	local u_purchase_rewardmgr = cls.new()
	u_purchase_rewardmgr:set_user(user)
	u_purchase_rewardmgr:load_db("fk", u:get_csv_id())
	u_purchase_rewardmgr:set_user(u)
	self._data["u_purchase_rewardmgr"] = u_purchase_rewardmgr
	u.u_purchase_rewardmgr = u_purchase_rewardmgr
end

function cls:get_u_purchase_rewardmgr( ... )
	-- body
	return self._data["u_purchase_rewardmgr"]
end

function cls:load_u_recharge_count(user)
	-- body
	local u = self:get_user()
	local cls = require "models/u_recharge_countmgr"
	local u_recharge_countmgr = cls.new()
	u_recharge_countmgr:set_user(u)
	u_recharge_countmgr:load_db("fk", u:get_field("csv_id"))
	u_recharge_countmgr:set_user(u)
	self._data["u_recharge_countmgr"] = u_recharge_countmgr
	u.u_recharge_countmgr = u_recharge_countmgr
end

function cls:get_u_recharge_countmgr( ... )
	-- body
	return self._data["u_recharge_countmgr"]
end

function cls:load_u_recharge_record(user)
	-- body
	local u = self:get_user()
	local cls = require "models/u_recharge_recordmgr"
	local u_recharge_recordmgr = cls.new()
	u_recharge_recordmgr:set_user(u)
	u_recharge_recordmgr:load_db("fk", u:get_field("csv_id"))
	u_recharge_recordmgr:set_user(u)
	self._data["u_recharge_recordmgr"] = u_recharge_recordmgr
	u.u_recharge_recordmgr = u_recharge_recordmgr
end

function cls:get_u_recharge_recordmgr( ... )
	-- body
	return self._data["u_recharge_recordmgr"]
end

function cls:load_u_recharge_reward()
	-- body
	local u = self:get_user()
	local cls = require "models/u_recharge_rewardmgr"
	local u_recharge_rewardmgr = cls.new()
	u_recharge_rewardmgr:set_user(user)
	u_recharge_rewardmgr:load_db("fk", user.csv_id)
	u_recharge_rewardmgr:set_user(u)
	self._data["u_recharge_rewardmgr"] = u_recharge_rewardmgr
	u.u_recharge_rewardmgr = u_recharge_rewardmgr
end

function cls:get_u_recharge_recordmgr( ... )
	-- body
	return self._data["u_recharge_rewardmgr"]
end

function cls:load_u_recharge_vip_reward()
	-- body
	local u = self:get_user()
	local cls = require "models/u_recharge_vip_rewardmgr"
	local u_recharge_vip_rewardmgr = cls.new()
	u_recharge_vip_rewardmgr:set_user(u)
	u_recharge_vip_rewardmgr:load_db("fk", u:get_field("csv_id"))
	self._data["u_recharge_vip_rewardmgr"] = u_recharge_vip_rewardmgr
	u.u_recharge_vip_rewardmgr = u_recharge_vip_rewardmgr
end

function cls:get_u_recharge_vip_rewardmgr( ... )
	-- body
	return self._data["u_recharge_vip_rewardmgr"]
end

function cls:load_u_role_remote(p, ... )
	-- body
	local u = self:get_user()
	local cls = require "models/u_rolemgr"
	local u_rolemgr = cls.new()
	u_rolemgr:set_user(user)
	local r = p[u_rolemgr.__tname]
	u_rolemgr:load_remote(r)
	u_rolemgr:set_user(u)
	self._data[u_rolemgr.__tname.."mgr"] = u_rolemgr
	u.u_rolemgr = u_rolemgr
end

function cls:gen_u_role_remote(rm, ... )
	-- body
	local r = {}
	local u_rolemgr = self:get_u_rolemgr()
	for k,v in pairs(u_rolemgr.__data) do
		table.insert(r, v.__fields)
	end
	rm[u_rolemgr.__tname] = r
end

function cls:load_u_role(user)
	-- body
	local u = self:get_user()
	local cls = require "models/u_rolemgr"
	local u_rolemgr = cls.new()
	u_rolemgr:set_user(u)
	u_rolemgr:load_db("fk", u:get_field("csv_id"))
	u_rolemgr:load_data_to_cache()
	self._data["u_rolemgr"] = u_rolemgr
	u.u_rolemgr = u_rolemgr
end

function cls:get_u_rolemgr( ... )
	-- body
	return self._data["u_rolemgr"]
end

function cls:load_u_journal(user)
	-- body
	local u = self:get_user()
	local cls = require "models/u_journalmgr"
	local u_journalmgr = cls.new()
	u_journalmgr:set_user(u)
	u_journalmgr:load_db("fk", u:get_field("csv_id"))
	self._data["u_journalmgr"] = u_journalmgr
	u.u_journalmgr = u_journalmgr
end

function cls:get_u_journalmgr( ... )
	-- body
	return self._data["u_journalmgr"]
end

function cls:load_u_goods(user)
	-- body
	local u = self:get_user()
	local cls = require "models/u_goodsmgr"
	local u_goodsmgr = cls.new()
	u_goodsmgr:set_user(u)
	u_goodsmgr:load_db("fk", u:get_csv_id())
	self._data["u_goodsmgr"] = u_goodsmgr
	u.u_goodsmgr = u_goodsmgr
end

function cls:get_u_goodsmgr( ... )
	-- body
	return self._data["u_goodsmgr"]
end

function cls:load_u_ara_worship( ... )
	-- body
	local u = self:get_user()
	local cls = require "models/u_ara_worshipmgr"
	local u_ara_worshipmgr = cls.new()
	u_ara_worshipmgr:set_user(u)
	u_ara_worshipmgr:load_db("fk", u:get_csv_id())
	self._data["u_ara_worshipmgr"] = u_ara_worshipmgr
	u.u_ara_worshipmgr = u_ara_worshipmgr
end

function cls:get_u_ara_worshipmgr( ... )
	-- body
	return self._data["u_ara_worshipmgr"]
end

function cls:load_u_ara_worship_rc( ... )
	-- body
	local u = self:get_user()
	local cls = require "models/u_ara_worship_rcmgr"
	local u_ara_worship_rcmgr = cls.new()
	u_ara_worship_rcmgr:set_user(u)
	self._data["u_ara_worship_rcmgr"] = u_ara_worship_rcmgr
	u.u_ara_worship_rcmgr = u_ara_worship_rcmgr
end

function cls:get_u_ara_worship_rcmgr( ... )
	-- body
	return self._data["u_ara_worship_rcmgr"]
end

function cls:load_u_ara_pts( ... )
	-- body
	local u = self:get_user()
	local cls = require "models/u_ara_ptsmgr"
	local u_ara_ptsmgr = cls.new()
	u_ara_ptsmgr:set_user(u)
	u_ara_ptsmgr:load_db("fk", u:get_field("csv_id"))
	self._data["u_ara_ptsmgr"] = u_ara_ptsmgr
end

function cls:get_u_ara_ptsmgr( ... )
	-- body
	return self._data["u_ara_ptsmgr"]
end

function cls:load_u_ara_rnk_rwd( ... )
	-- body
	local u = self:get_user()
	local cls = require "models/u_ara_rnk_rwdmgr"
	local u_ara_rnk_rwdmgr = cls.new()
	u_ara_rnk_rwdmgr:set_user(u)
	u_ara_rnk_rwdmgr:load_db("fk", u:get_field("csv_id"))
	self._data["u_ara_rnk_rwdmgr"] = u_ara_rnk_rwdmgr
end

function cls:get_u_ara_rnk_rwdmgr( ... )
	-- body
	return self._data["u_ara_rnk_rwdmgr"]
end

return cls
