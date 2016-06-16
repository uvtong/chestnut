local skynet = require "skynet"
local sd = require "sharedata"
local MAXEMAILNUM = 50

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
		cp_chapter=1,
		cp_type = 0,
		cp_id = 1,
		cp_checkpoint = 1,
		cp_drop_id1 = 0,
		cp_drop_id2 = 0,
		cp_drop_id3 = 0,
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
		ara_r1_sum_combat = 0,
		ara_r1_sum_defense = 0,
		ara_r1_sum_critical_hit = 0,
		ara_r1_sum_king = 0,
		ara_rfh_st = 0,
		ara_rfh_cd = 0,
		ara_rfh_cd_cost_tms = 0,
		ara_clg_tms_rsttm = 0,
		ara_clg_cost_rsttm = 0,
		ara_integral_rsttm = 0,
		draw_num = 0,
		ara_r2_sum_combat = 0,
		ara_r2_sum_defense = 0,
		ara_r2_sum_critical_hit = 0,
		ara_r2_sum_king = 0,
		ara_r3_sum_combat = 0,
		ara_r3_sum_defense = 0,
		ara_r3_sum_critical_hit = 0,
		ara_r3_sum_king = 0,
		daily_recv_heart = 0,
		friend_update_time = 0,
		cp_fighting = 0,
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

	for k, v in pairs(c.__data) do
		return v
	end

	return nil
end 
	
function cls:checkin_month_get_checkin_month()
	local modelmgr = self._env:get_modelmgr()
	assert(modelmgr)
	local cm = modelmgr:get_u_checkin_monthmgr()
	assert(cm)
	
	for k, v in pairs(cm.__data) do
		return v
	end
	
	return nil
end 
	
function cls:email_recvemail(tvals)
	assert(tvals)
	local modelmgr = self._env:get_modelmgr()
	assert(modelmgr)
	local e = modelmgr:get_u_new_emailmgr()
	assert(e)
	
	if e:get_count() >= MAXEMAILNUM then
		--cls:email_sysdelemail()
	end
	
	local newemail = e:create( tvals )
	assert( newemail )
	e:add( newemail )
	newemail:update_db()
	
	print("add email succe in recvemail\n")
	return newemail
end 
	
function cls:email_sysdelemail()
	assert(tvals)
	local modelmgr = self.env:get_modelmgr()
	assert(modelmgr)
	local e = modelmgr:get_u_modelmgr()
	assert(e)
	
	local i = 1
	for k ,  v in pairs( self.__data ) do
		if true == v.isread then
			if true == v.isreward then
				table.insert( readrewarded , v.csv_id )
			else
				table.insert( readunrewarded , v.csv_id )
			end
		else
			table.insert( unread , { v.csv_id , v.acctime } )
		end 
	end	
  --delete read and getrewarded first  

	for _ , v in ipairs( readrewarded ) do
		self.__data[ tostring( v.csv_id ) ] = nil 
		self.__count = self.__count - 1
	end

	if self.__count <= MAXEMAILNUM then
		return
	end
  -- if still more than MAXEMAILNUMM then delete read , unrewarded 	
	for _ , v in ipairs( readunrewarded ) do
		self.__data[ tostring( v.csv_id ) ] = nil
		self.__count = self.__count - 1 
	end
	
	if self.__count <= MAXEMAILNUM then
		return
	end
 	
 	-- last delete the earlist unread emails  
	table.sort( unread , function ( a , b )  
			return ( a.acctime < b.acctime )
		end )
	
	local diff = self.__count - MAXEMAILNUM

	for i = 1 , diff do
		self.__data[ tostring( unread[ i ].csv_id ) ] = nil
		self.__count = self.__count - 1
	end
end

function cls:get_prop(csv_id, ... )
	-- body
	local user = self._env:get_user()
	local modelmgr = self._env:get_modelmgr()
	local u_propmgr = modelmgr:get_u_propmgr()
	local p = u_propmgr:get_by_csv_id(csv_id)
	if p then
		return p
	else
		local key = string.format("%s:%d", "g_prop", csv_id)
		local p = sd.query(key)
		p.user_id = user:get_field("csv_id")
		p.num = 0
		p.id = genpk_2(p.user_id, p.csv_id)
		p = u_propmgr:create(p)
		user.u_propmgr:add(p)
		p:update_db()
		return p
	end
end

function cls:get_goods(csv_id, ... )
	-- body
	local user = self._env:get_user()
	local p = user.u_goodsmgr:get_by_csv_id(csv_id)
	if p then
		return p
	else
		p = skynet.call(game, "lua", "query_g_goods", csv_id)
		p.user_id = user.csv_id
		p.inventory = p.inventory_init
		p.countdown = 0
		p.st = 0
		p = user.u_goodsmgr.create(p)
		user.u_goodsmgr:add(p)
		p:update_db(const.DB_PRIORITY_2)
	end
end

return cls
	
