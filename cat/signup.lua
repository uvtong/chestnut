local skynet = require "skynet"
local u_achievementmgr = require "models/u_achievementmgr"
local u_achievement_rcmgr = require "models/u_achievement_rcmgr"
local u_ara_batmgr = require "models/u_ara_batmgr"
local u_ara_rnk_rwdmgr = require "models/u_ara_rnk_rwdmgr"
local u_cgoldmgr = require "models/u_cgoldmgr"
local u_checkinmgr = require "models/u_checkinmgr"
local u_checkin_monthmgr = require "models/u_checkin_monthmgr"
local u_checkpointmgr = require "models/u_checkpointmgr"
local u_checkpoint_rcmgr = require "models/u_checkpoint_rcmgr"
local u_equipmentmgr = require "models/u_equipmentmgr"
local u_exercisemgr = require "models/u_exercisemgr"
-- local u_friendmgr = require "models/u_friendmgr"
-- local u_friendmsgmgr = require "models/u_friendmsgmgr"
local u_goodsmgr = require "models/u_goodsmgr"
local u_journalmgr = require "models/u_journalmgr"
local u_kungfumgr = require "models/u_kungfumgr"
local u_lilian_mainmgr = require "models/u_lilian_mainmgr"
local u_lilian_phy_powermgr = require "models/u_lilian_phy_powermgr"
local u_lilian_qg_nummgr = require "models/u_lilian_qg_nummgr"
local u_lilian_submgr = require "models/u_lilian_submgr"
-- local u_new_drawmgr = require "models/u_new_drawmgr"
-- local u_new_emailmgr = require "models/u_new_emailmgr"
local u_propmgr = require "models/u_propmgr"
local u_purchase_goodsmgr = require "models/u_purchase_goodsmgr"
local u_purchase_rewardmgr = require "models/u_purchase_rewardmgr"
local u_recharge_countmgr = require "models/u_recharge_countmgr"
local u_recharge_recordmgr = require "models/u_recharge_recordmgr"
local u_recharge_vip_rewardmgr = require "models/u_recharge_vip_rewardmgr"
local u_rolemgr = require "models/u_rolemgr"
local usersmgr = require "models/usersmgr"
local const = require "const"
local errorcode = require "errorcode"
local game = ".game"

local function signup(uid, xilian)
	-- body

	local u = usersmgr.create_default(uid)
	local res = u:__insert_db_wait(const.DB_PRIORITY_1)
	print("****************************abc")
	if res.errno then
		return nil
	end
	u.u_achievementmgr = u_achievementmgr
	u.u_achievement_rcmgr = u_achievement_rcmgr
	u.u_ara_batmgr = u_ara_batmgr
	u.u_ara_rnk_rwdmgr = u_ara_rnk_rwdmgr
	u.u_cgoldmgr = u_cgoldmgr
	u.u_checkinmgr = u_checkinmgr
	u.u_checkin_monthmgr = u_checkin_monthmgr
	u.u_checkpointmgr = u_checkpointmgr
	u.u_checkpoint_rcmgr = u_checkpoint_rcmgr
	u.u_ara_batmgr  = u_ara_batmgr
	u.u_ara_rnk_rwdmgr = u_ara_rnk_rwdmgr
	u.u_cgoldmgr = u_cgoldmgr
	u.u_checkinmgr = u_checkinmgr
	u.u_checkin_monthmgr = u_checkin_monthmgr 
	u.u_checkpointmgr = u_checkpointmgr
	u.u_checkpoint_rcmgr = u_checkpoint_rcmgr
	u.u_equipmentmgr = u_equipmentmgr
	u.u_exercisemgr = u_exercisemgr
	-- u.u_friendmgr = u_friendmgr
	-- u.u_friendmsgmgr = u_friendmsgmgr
	u.u_goodsmgr = u_goodsmgr
	u.u_journalmgr = u_journalmgr
	u.u_kungfumgr = u_kungfumgr
	u.u_lilian_mainmgr = u_lilian_mainmgr
	u.u_lilian_phy_powermgr = u_lilian_phy_powermgr
	u.u_lilian_qg_nummgr = u_lilian_qg_nummgr
	u.u_lilian_submgr = u_lilian_submgr
	-- u.u_new_drawmgr = u_new_drawmgr
	-- u.u_new_emailmgr = u_new_emailmgr 
	u.u_propmgr = u_propmgr
	u.u_purchase_goodsmgr = u_purchase_goodsmgr
	u.u_purchase_rewardmgr = u_purchase_rewardmgr
	u.u_recharge_recordmgr = u_recharge_recordmgr
	u.u_recharge_vip_rewardmgr = u_recharge_vip_rewardmgr
	u.u_rolemgr = u_rolemgr

	local l = {}
	local r = skynet.call(game, "lua", "query_g_equipment")
	for k,v in pairs(r) do
		local equip = skynet.call(game, "lua", "query_g_equipment_enhance", v.csv_id*1000+v.level)
		equip.user_id = u.csv_id
		local equip = u_equipmentmgr.create(equip)
		u_equipmentmgr:add(equip)
		table.insert(l, equip)
	end
	u_equipmentmgr.insert_db(l, const.DB_PRIORITY_1)

	l = {}
	local prop = skynet.call(game, "lua", "query_g_prop", const.GOLD)
	prop.user_id = u.csv_id
	prop.num = 100
	prop = u_propmgr.create(prop)
	table.insert(l, prop)

	prop = skynet.call(game, "lua", "query_g_prop", const.DIAMOND)
	prop.user_id = u.csv_id
	prop.num = 100
	prop = u_propmgr.create(prop)
	table.insert(l, prop)

	prop = skynet.call(game, "lua", "query_g_prop", const.EXP)
	prop.user_id = u.csv_id
	prop.num = 100
	prop = u_propmgr.create(prop)
	table.insert(l, prop)
	
	prop = skynet.call(game, "lua", "query_g_prop", const.LOVE)
	prop.user_id = u.csv_id
	prop.num = 100     
	prop = u_propmgr.create(prop)
	table.insert(l, prop)
	
	--add invitation
	prop = skynet.call( game , "lua" , "query_g_prop" , 50007)
	assert( prop )
	prop.user_id = u.csv_id
	prop.num = 100
	prop = u_propmgr.create(prop)
	table.insert( l , prop )
	
	u_propmgr.insert_db(l, const.DB_PRIORITY_1)

	local newemail = { 
					   type = 1 , title = "new user email" , 
					   content = "Welcome to the game" , 
					   itemsn1 = 1 , itemnum1 = 10000 , 
					   itemsn2 = 2 , itemnum2 = 10000 , 
					   itemsn3 = 3 , itemnum3 = 10000
					}  
	skynet.send(".channel", "lua", "send_email_to_group", newemail,  { { uid = u.csv_id } })

	local u_rolemgr = require "models/u_rolemgr"
	local role = skynet.call(game, "lua", "query_g_role", 1)
	local role_star = skynet.call(game, "lua", "query_g_role_star", role.csv_id*1000+role.star)
	for k,v in pairs(role_star) do
		role[k] = v
	end
	role.user_id = assert(u.csv_id)
	role.k_csv_id1 = 0
	role.k_csv_id2 = 0
	role.k_csv_id3 = 0
	role.k_csv_id4 = 0
	role.k_csv_id5 = 0
	role.k_csv_id6 = 0
	role.k_csv_id7 = 0
	local n, r = xilian(role, {role_id=role.csv_id, is_locked1=false, is_locked2=false, is_locked3=false, is_locked4=false, is_locked5=false})
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
	role = u_rolemgr.create(role)
	role:__insert_db(const.DB_PRIORITY_1)

	l = {}
	local u_achievementmgr = require "models/u_achievementmgr"
	for i=1,8 do
		local csv_id = i * 1000 + 1
		local a = skynet.call(game, "lua", "query_g_achievement", csv_id)
		a.user_id = u.csv_id
		a.finished = 0
		a.reward_collected = 0
		a.is_unlock = 1
		a.is_valid = 1
		a = u_achievementmgr.create(a)	
		table.insert(l, a)
		end
		u_achievementmgr.insert_db(l, const.DB_PRIORITY_1)

	local u_goodsmgr = require "models/u_goodsmgr"
	local r = skynet.call(game, "lua", "query_g_goods")
	l = {}
	for k,v in pairs(r) do
		local t = { user_id = u.csv_id, csv_id=v.csv_id, inventory=v.inventory_init, countdown=0, st=0}
		local a = u_goodsmgr.create(t)
		table.insert(l, a)
	end
	u_goodsmgr.insert_db(l, const.DB_PRIORITY_1)

	local u_checkpointmgr = require "models/u_checkpointmgr"
	local tmp = {
		user_id = u.csv_id,
		chapter = u.cp_chapter,
		chapter_type0 = 1,       
		chapter_type1 = 0,
		chapter_type2 = 0,
		chapter_type0_finished=0,
		chapter_type1_finished=0,
		chapter_type2_finished=0,
		finished=0
	}
	local cp = u_checkpointmgr.create(tmp)
	cp:__insert_db(const.DB_PRIORITY_1)
	return u
end

return signup