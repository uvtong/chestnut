local skynet = require "skynet"
local cls = class("factory")

function cls:ctor(env, ... )
	-- body
	self._env = env
end

function cls:create_journal(sec, ... )
	-- body
	local modelmgr = self._env:get_modelmgr()
	local u_journalmgr = modelmgr:get_u_journalmgr()
	local user = modelmgr:get_user()
	local t = {}
	t["id"] = genpk_2(user:get_field("csv_id"), sec)
	t["user_id"] = user:get_field("csv_id")
	t["date"] = sec
	t["goods_refresh_count"] = 0
	t["goods_refresh_reset_count"] = 0
	t["ara_rfh_tms"] = 5
	t["ara_bat_ser"] = 0
	local j = u_journalmgr:create_entity(t)
	u_journalmgr:add(j)
	j:update()
	return j
end 	
		
function cls:get_today( ... )
	-- body
	assert(type(self) == "table")
	local modelmgr = self._env:get_modelmgr()
	local u_journalmgr = modelmgr:get_u_journalmgr()
	local t = os.date("*t", os.time())
	t = { year=t.year, month=t.month, day=t.day}
	local sec = os.time(t)
	local j = u_journalmgr:get_by_csv_id(sec)
	if j then
		return j
	else
		return self:create_journal(sec)
	end
end

function cls:create_ara_bat(p )
	-- body
	local ser = p:get_ser()
	local tmp = {}
	tmp["id"] = genpk_2(self._user:get_csv_id(), ser)
	tmp["user_id"] = self._user:get_csv_id()
	tmp["csv_id"] = ser
	tmp["start_tm"] = p.start_tm
	tmp["end_tm"] = p.end_tm
	tmp["over"] = p.over
	tmp["res"] = p.res
	local modelmgr = self._env:get_modelemgr()
	local u_ara = 1
	local mgr = self
	local entity_cls = require "u_ara_batentity"
	local entity = entity_cls.new()
end 	
		
function cls:create_user(uid)
	-- body
	local game = self._env:get_game()
	local level = skynet.call(game, "lua", "query_g_user_level", 1)
	local vip = skynet.call(game, "lua", "query_g_recharge_vip_reward", 0)
	local t = { 
		csv_id= uid,
		uname="nihao",
		uviplevel=3,
		config_sound=1, 
		config_music=1, 
		avatar=0, 
		sign="peferct ", 
		c_role_id=1, 
		ifonline=0, 
		level=level.level, 
		combat=level.combat, 
		defense=level.defense, 
		critical_hit=level.critical_hit, 
		blessing=level.skill,
		permission = 1,
		group = 0, 
		modify_uname_count=0, 
		onlinetime=0, 
		iconid=0, 
		is_valid=1, 
		recharge_rmb=0, 
		goods_refresh_count=0, 
		recharge_diamond=0, 
		uvip_progress=0, 
		checkin_num=0, 
		checkin_reward_num=0, 
		exercise_level=0, 
		cgold_level=0,
		gold_max=level.gold_max + math.floor(level.gold_max * vip.gold_max_up_p/100),
		exp_max=level.exp_max + math.floor(level.exp_max * vip.exp_max_up_p/100),
		equipment_enhance_success_rate_up_p=assert(vip.equipment_enhance_success_rate_up_p),
		store_refresh_count_max=assert(vip.store_refresh_count_max),
		prop_refresh=0,
		arena_frozen_time=0,
		purchase_hp_count=0, 
		gain_gold_up_p=0,
		gain_exp_up_p=0,
		purchase_hp_count_max=4 ,--assert(vip.purchase_hp_count_max),
		SCHOOL_reset_count_max=assert(vip.SCHOOL_reset_count_max),
		SCHOOL_reset_count=0,
		signup_time=os.time() ,
		pemail_csv_id = 0,
		take_diamonds=0,
		draw_number=0 ,
		ifxilian = 0,              -- 
		cp_chapter=1,                 -- checkpoint progress 1
		cp_hanging_id=1001,
		cp_battle_id=0,
		cp_battle_chapter=0,
		lilian_level = 1,
		lilian_exp = 0,
		lilian_phy_power = 120,
		purch_lilian_phy_power = 0,
		ara_role_id1 = 0,
		ara_role_id2 = 0,
		ara_role_id3 = 0,
		ara_win_tms = 0,
		ara_lose_tms = 0,
		ara_tie_tms = 0,
		ara_clg_tms = 5,
		ara_clg_tms_pur_tms = 5,
		ara_integral = 0,
		ara_fighting = 0,
		ara_interface = 0,
		ara_rfh_cost_tms = 0,
		ara_clg_cost_tms = 0,
		sum_combat = 0,
		sum_defense = 0,
		sum_critical_hit = 0,
		sum_king = 0,
	}
	local usersmgr = self._env:get_usersmgr()
	local user = usersmgr:create_entity(t)
	return user
end

function cls:draw_get_by_type(drawtype)
	assert(drawtype)
	local modelmgr = self._env:get_modelmgr()
	local d = modelmgr:get_u_drawmgr()
	assert(d)
	for k, v in pairs(d.__data) do
		if v.drawtype == drawtype then
			return v
		end
	end

	return nil
end 

function cls:checkin_get_checkin()
	local modelmgr = self._env:get_modelmgr()
	assert(modelmgr)
	local c = modelmgr:get_u_checkinmgr()
	assert(c)

	return c.__data[1]
end

function cls:checkin_month_get_checkin_month()
	local modelmgr = self._env:get_modelmgr()
	assert(modelmgr)
	local cm = modelmgr:get_u_checkin_month()
	assert(cm)

	return cm.__data[1]
end

return cls