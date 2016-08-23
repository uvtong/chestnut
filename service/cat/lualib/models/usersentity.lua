local entitycpp = require "entitycpp"

local cls = class("usersentity", entitycpp)

function cls:ctor(mgr, P, ... )
	-- body
	self.__head  = mgr.__head
	self.__head_ord = mgr.__head_ord
	self.__tname = mgr.__tname
	self.__pk    = mgr.__pk
	self.__fk    = mgr.__fk
	self.__rdb   = mgr.__rdb
	self.__wdb   = mgr.__wdb
	self.__stm   = mgr.__stm
	self.__col_updated=0
	self.__fields = {
			csv_id = 0,
			uname = 0,
			uviplevel = 0,
			config_sound = 0,
			config_music = 0,
			avatar = 0,
			sign = 0,
			c_role_id = 0,
			ifonline = 0,
			level = 0,
			combat = 0,
			defense = 0,
			critical_hit = 0,
			blessing = 0,
			permission = 0,
			modify_uname_count = 0,
			onlinetime = 0,
			iconid = 0,
			is_valid = 0,
			recharge_rmb = 0,
			recharge_diamond = 0,
			uvip_progress = 0,
			checkin_num = 0,
			checkin_reward_num = 0,
			exercise_level = 0,
			cgold_level = 0,
			gold_max = 0,
			exp_max = 0,
			equipment_enhance_success_rate_up_p = 0,
			store_refresh_count_max = 0,
			prop_refresh = 0,
			arena_frozen_time = 0,
			purchase_hp_count = 0,
			gain_gold_up_p = 0,
			gain_exp_up_p = 0,
			purchase_hp_count_max = 0,
			SCHOOL_reset_count_max = 0,
			SCHOOL_reset_count = 0,
			signup_time = 0,
			pemail_csv_id = 0,
			take_diamonds = 0,
			draw_number = 0,
			ifxilian = 0,
			cp_chapter = 0,
			cp_type = 0,
			cp_checkpoint = 0,
			cp_id = 0,
			cp_drop_id1 = 0,
			cp_drop_id2 = 0,
			cp_drop_id3 = 0,
			cp_fighting = 0,
			lilian_level = 0,
			lilian_exp = 0,
			lilian_phy_power = 0,
			purch_lilian_phy_power = 0,
			ara_role_id1 = 0,
			ara_role_id2 = 0,
			ara_role_id3 = 0,
			ara_win_tms = 0,
			ara_lose_tms = 0,
			ara_tie_tms = 0,
			ara_clg_tms = 0,
			ara_clg_cost_tms = 0,
			ara_integral = 0,
			ara_fighting = 0,
			ara_interface = 0,
			ara_rfh_cost_tms = 0,
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
		}

	self.__ecol_updated = {
			csv_id = 0,
			uname = 0,
			uviplevel = 0,
			config_sound = 0,
			config_music = 0,
			avatar = 0,
			sign = 0,
			c_role_id = 0,
			ifonline = 0,
			level = 0,
			combat = 0,
			defense = 0,
			critical_hit = 0,
			blessing = 0,
			permission = 0,
			modify_uname_count = 0,
			onlinetime = 0,
			iconid = 0,
			is_valid = 0,
			recharge_rmb = 0,
			recharge_diamond = 0,
			uvip_progress = 0,
			checkin_num = 0,
			checkin_reward_num = 0,
			exercise_level = 0,
			cgold_level = 0,
			gold_max = 0,
			exp_max = 0,
			equipment_enhance_success_rate_up_p = 0,
			store_refresh_count_max = 0,
			prop_refresh = 0,
			arena_frozen_time = 0,
			purchase_hp_count = 0,
			gain_gold_up_p = 0,
			gain_exp_up_p = 0,
			purchase_hp_count_max = 0,
			SCHOOL_reset_count_max = 0,
			SCHOOL_reset_count = 0,
			signup_time = 0,
			pemail_csv_id = 0,
			take_diamonds = 0,
			draw_number = 0,
			ifxilian = 0,
			cp_chapter = 0,
			cp_type = 0,
			cp_checkpoint = 0,
			cp_id = 0,
			cp_drop_id1 = 0,
			cp_drop_id2 = 0,
			cp_drop_id3 = 0,
			cp_fighting = 0,
			lilian_level = 0,
			lilian_exp = 0,
			lilian_phy_power = 0,
			purch_lilian_phy_power = 0,
			ara_role_id1 = 0,
			ara_role_id2 = 0,
			ara_role_id3 = 0,
			ara_win_tms = 0,
			ara_lose_tms = 0,
			ara_tie_tms = 0,
			ara_clg_tms = 0,
			ara_clg_cost_tms = 0,
			ara_integral = 0,
			ara_fighting = 0,
			ara_interface = 0,
			ara_rfh_cost_tms = 0,
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
		}

	for k,v in pairs(self.__head) do
		self.__fields[k] = assert(P[k], string.format("no exist %s", k))
	end
	return self
end

function cls:set_csv_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["csv_id"] = self.__ecol_updated["csv_id"] + 1
	if self.__ecol_updated["csv_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.csv_id = v
end

function cls:get_csv_id( ... )
	-- body
	return self.__fields.csv_id
end

function cls:set_uname(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["uname"] = self.__ecol_updated["uname"] + 1
	if self.__ecol_updated["uname"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.uname = v
end

function cls:get_uname( ... )
	-- body
	return self.__fields.uname
end

function cls:set_uviplevel(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["uviplevel"] = self.__ecol_updated["uviplevel"] + 1
	if self.__ecol_updated["uviplevel"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.uviplevel = v
end

function cls:get_uviplevel( ... )
	-- body
	return self.__fields.uviplevel
end

function cls:set_config_sound(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["config_sound"] = self.__ecol_updated["config_sound"] + 1
	if self.__ecol_updated["config_sound"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.config_sound = v
end

function cls:get_config_sound( ... )
	-- body
	return self.__fields.config_sound
end

function cls:set_config_music(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["config_music"] = self.__ecol_updated["config_music"] + 1
	if self.__ecol_updated["config_music"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.config_music = v
end

function cls:get_config_music( ... )
	-- body
	return self.__fields.config_music
end

function cls:set_avatar(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["avatar"] = self.__ecol_updated["avatar"] + 1
	if self.__ecol_updated["avatar"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.avatar = v
end

function cls:get_avatar( ... )
	-- body
	return self.__fields.avatar
end

function cls:set_sign(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["sign"] = self.__ecol_updated["sign"] + 1
	if self.__ecol_updated["sign"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.sign = v
end

function cls:get_sign( ... )
	-- body
	return self.__fields.sign
end

function cls:set_c_role_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["c_role_id"] = self.__ecol_updated["c_role_id"] + 1
	if self.__ecol_updated["c_role_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.c_role_id = v
end

function cls:get_c_role_id( ... )
	-- body
	return self.__fields.c_role_id
end

function cls:set_ifonline(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ifonline"] = self.__ecol_updated["ifonline"] + 1
	if self.__ecol_updated["ifonline"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ifonline = v
end

function cls:get_ifonline( ... )
	-- body
	return self.__fields.ifonline
end

function cls:set_level(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["level"] = self.__ecol_updated["level"] + 1
	if self.__ecol_updated["level"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.level = v
end

function cls:get_level( ... )
	-- body
	return self.__fields.level
end

function cls:set_combat(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["combat"] = self.__ecol_updated["combat"] + 1
	if self.__ecol_updated["combat"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.combat = v
end

function cls:get_combat( ... )
	-- body
	return self.__fields.combat
end

function cls:set_defense(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["defense"] = self.__ecol_updated["defense"] + 1
	if self.__ecol_updated["defense"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.defense = v
end

function cls:get_defense( ... )
	-- body
	return self.__fields.defense
end

function cls:set_critical_hit(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["critical_hit"] = self.__ecol_updated["critical_hit"] + 1
	if self.__ecol_updated["critical_hit"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.critical_hit = v
end

function cls:get_critical_hit( ... )
	-- body
	return self.__fields.critical_hit
end

function cls:set_blessing(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["blessing"] = self.__ecol_updated["blessing"] + 1
	if self.__ecol_updated["blessing"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.blessing = v
end

function cls:get_blessing( ... )
	-- body
	return self.__fields.blessing
end

function cls:set_permission(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["permission"] = self.__ecol_updated["permission"] + 1
	if self.__ecol_updated["permission"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.permission = v
end

function cls:get_permission( ... )
	-- body
	return self.__fields.permission
end

function cls:set_modify_uname_count(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["modify_uname_count"] = self.__ecol_updated["modify_uname_count"] + 1
	if self.__ecol_updated["modify_uname_count"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.modify_uname_count = v
end

function cls:get_modify_uname_count( ... )
	-- body
	return self.__fields.modify_uname_count
end

function cls:set_onlinetime(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["onlinetime"] = self.__ecol_updated["onlinetime"] + 1
	if self.__ecol_updated["onlinetime"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.onlinetime = v
end

function cls:get_onlinetime( ... )
	-- body
	return self.__fields.onlinetime
end

function cls:set_iconid(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["iconid"] = self.__ecol_updated["iconid"] + 1
	if self.__ecol_updated["iconid"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.iconid = v
end

function cls:get_iconid( ... )
	-- body
	return self.__fields.iconid
end

function cls:set_is_valid(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["is_valid"] = self.__ecol_updated["is_valid"] + 1
	if self.__ecol_updated["is_valid"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.is_valid = v
end

function cls:get_is_valid( ... )
	-- body
	return self.__fields.is_valid
end

function cls:set_recharge_rmb(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["recharge_rmb"] = self.__ecol_updated["recharge_rmb"] + 1
	if self.__ecol_updated["recharge_rmb"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.recharge_rmb = v
end

function cls:get_recharge_rmb( ... )
	-- body
	return self.__fields.recharge_rmb
end

function cls:set_recharge_diamond(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["recharge_diamond"] = self.__ecol_updated["recharge_diamond"] + 1
	if self.__ecol_updated["recharge_diamond"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.recharge_diamond = v
end

function cls:get_recharge_diamond( ... )
	-- body
	return self.__fields.recharge_diamond
end

function cls:set_uvip_progress(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["uvip_progress"] = self.__ecol_updated["uvip_progress"] + 1
	if self.__ecol_updated["uvip_progress"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.uvip_progress = v
end

function cls:get_uvip_progress( ... )
	-- body
	return self.__fields.uvip_progress
end

function cls:set_checkin_num(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["checkin_num"] = self.__ecol_updated["checkin_num"] + 1
	if self.__ecol_updated["checkin_num"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.checkin_num = v
end

function cls:get_checkin_num( ... )
	-- body
	return self.__fields.checkin_num
end

function cls:set_checkin_reward_num(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["checkin_reward_num"] = self.__ecol_updated["checkin_reward_num"] + 1
	if self.__ecol_updated["checkin_reward_num"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.checkin_reward_num = v
end

function cls:get_checkin_reward_num( ... )
	-- body
	return self.__fields.checkin_reward_num
end

function cls:set_exercise_level(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["exercise_level"] = self.__ecol_updated["exercise_level"] + 1
	if self.__ecol_updated["exercise_level"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.exercise_level = v
end

function cls:get_exercise_level( ... )
	-- body
	return self.__fields.exercise_level
end

function cls:set_cgold_level(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["cgold_level"] = self.__ecol_updated["cgold_level"] + 1
	if self.__ecol_updated["cgold_level"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.cgold_level = v
end

function cls:get_cgold_level( ... )
	-- body
	return self.__fields.cgold_level
end

function cls:set_gold_max(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["gold_max"] = self.__ecol_updated["gold_max"] + 1
	if self.__ecol_updated["gold_max"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.gold_max = v
end

function cls:get_gold_max( ... )
	-- body
	return self.__fields.gold_max
end

function cls:set_exp_max(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["exp_max"] = self.__ecol_updated["exp_max"] + 1
	if self.__ecol_updated["exp_max"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.exp_max = v
end

function cls:get_exp_max( ... )
	-- body
	return self.__fields.exp_max
end

function cls:set_equipment_enhance_success_rate_up_p(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["equipment_enhance_success_rate_up_p"] = self.__ecol_updated["equipment_enhance_success_rate_up_p"] + 1
	if self.__ecol_updated["equipment_enhance_success_rate_up_p"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.equipment_enhance_success_rate_up_p = v
end

function cls:get_equipment_enhance_success_rate_up_p( ... )
	-- body
	return self.__fields.equipment_enhance_success_rate_up_p
end

function cls:set_store_refresh_count_max(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["store_refresh_count_max"] = self.__ecol_updated["store_refresh_count_max"] + 1
	if self.__ecol_updated["store_refresh_count_max"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.store_refresh_count_max = v
end

function cls:get_store_refresh_count_max( ... )
	-- body
	return self.__fields.store_refresh_count_max
end

function cls:set_prop_refresh(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["prop_refresh"] = self.__ecol_updated["prop_refresh"] + 1
	if self.__ecol_updated["prop_refresh"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.prop_refresh = v
end

function cls:get_prop_refresh( ... )
	-- body
	return self.__fields.prop_refresh
end

function cls:set_arena_frozen_time(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["arena_frozen_time"] = self.__ecol_updated["arena_frozen_time"] + 1
	if self.__ecol_updated["arena_frozen_time"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.arena_frozen_time = v
end

function cls:get_arena_frozen_time( ... )
	-- body
	return self.__fields.arena_frozen_time
end

function cls:set_purchase_hp_count(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["purchase_hp_count"] = self.__ecol_updated["purchase_hp_count"] + 1
	if self.__ecol_updated["purchase_hp_count"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.purchase_hp_count = v
end

function cls:get_purchase_hp_count( ... )
	-- body
	return self.__fields.purchase_hp_count
end

function cls:set_gain_gold_up_p(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["gain_gold_up_p"] = self.__ecol_updated["gain_gold_up_p"] + 1
	if self.__ecol_updated["gain_gold_up_p"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.gain_gold_up_p = v
end

function cls:get_gain_gold_up_p( ... )
	-- body
	return self.__fields.gain_gold_up_p
end

function cls:set_gain_exp_up_p(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["gain_exp_up_p"] = self.__ecol_updated["gain_exp_up_p"] + 1
	if self.__ecol_updated["gain_exp_up_p"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.gain_exp_up_p = v
end

function cls:get_gain_exp_up_p( ... )
	-- body
	return self.__fields.gain_exp_up_p
end

function cls:set_purchase_hp_count_max(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["purchase_hp_count_max"] = self.__ecol_updated["purchase_hp_count_max"] + 1
	if self.__ecol_updated["purchase_hp_count_max"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.purchase_hp_count_max = v
end

function cls:get_purchase_hp_count_max( ... )
	-- body
	return self.__fields.purchase_hp_count_max
end

function cls:set_SCHOOL_reset_count_max(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["SCHOOL_reset_count_max"] = self.__ecol_updated["SCHOOL_reset_count_max"] + 1
	if self.__ecol_updated["SCHOOL_reset_count_max"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.SCHOOL_reset_count_max = v
end

function cls:get_SCHOOL_reset_count_max( ... )
	-- body
	return self.__fields.SCHOOL_reset_count_max
end

function cls:set_SCHOOL_reset_count(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["SCHOOL_reset_count"] = self.__ecol_updated["SCHOOL_reset_count"] + 1
	if self.__ecol_updated["SCHOOL_reset_count"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.SCHOOL_reset_count = v
end

function cls:get_SCHOOL_reset_count( ... )
	-- body
	return self.__fields.SCHOOL_reset_count
end

function cls:set_signup_time(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["signup_time"] = self.__ecol_updated["signup_time"] + 1
	if self.__ecol_updated["signup_time"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.signup_time = v
end

function cls:get_signup_time( ... )
	-- body
	return self.__fields.signup_time
end

function cls:set_pemail_csv_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["pemail_csv_id"] = self.__ecol_updated["pemail_csv_id"] + 1
	if self.__ecol_updated["pemail_csv_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.pemail_csv_id = v
end

function cls:get_pemail_csv_id( ... )
	-- body
	return self.__fields.pemail_csv_id
end

function cls:set_take_diamonds(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["take_diamonds"] = self.__ecol_updated["take_diamonds"] + 1
	if self.__ecol_updated["take_diamonds"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.take_diamonds = v
end

function cls:get_take_diamonds( ... )
	-- body
	return self.__fields.take_diamonds
end

function cls:set_draw_number(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["draw_number"] = self.__ecol_updated["draw_number"] + 1
	if self.__ecol_updated["draw_number"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.draw_number = v
end

function cls:get_draw_number( ... )
	-- body
	return self.__fields.draw_number
end

function cls:set_ifxilian(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ifxilian"] = self.__ecol_updated["ifxilian"] + 1
	if self.__ecol_updated["ifxilian"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ifxilian = v
end

function cls:get_ifxilian( ... )
	-- body
	return self.__fields.ifxilian
end

function cls:set_cp_chapter(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["cp_chapter"] = self.__ecol_updated["cp_chapter"] + 1
	if self.__ecol_updated["cp_chapter"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.cp_chapter = v
end

function cls:get_cp_chapter( ... )
	-- body
	return self.__fields.cp_chapter
end

function cls:set_cp_type(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["cp_type"] = self.__ecol_updated["cp_type"] + 1
	if self.__ecol_updated["cp_type"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.cp_type = v
end

function cls:get_cp_type( ... )
	-- body
	return self.__fields.cp_type
end

function cls:set_cp_checkpoint(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["cp_checkpoint"] = self.__ecol_updated["cp_checkpoint"] + 1
	if self.__ecol_updated["cp_checkpoint"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.cp_checkpoint = v
end

function cls:get_cp_checkpoint( ... )
	-- body
	return self.__fields.cp_checkpoint
end

function cls:set_cp_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["cp_id"] = self.__ecol_updated["cp_id"] + 1
	if self.__ecol_updated["cp_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.cp_id = v
end

function cls:get_cp_id( ... )
	-- body
	return self.__fields.cp_id
end

function cls:set_cp_drop_id1(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["cp_drop_id1"] = self.__ecol_updated["cp_drop_id1"] + 1
	if self.__ecol_updated["cp_drop_id1"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.cp_drop_id1 = v
end

function cls:get_cp_drop_id1( ... )
	-- body
	return self.__fields.cp_drop_id1
end

function cls:set_cp_drop_id2(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["cp_drop_id2"] = self.__ecol_updated["cp_drop_id2"] + 1
	if self.__ecol_updated["cp_drop_id2"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.cp_drop_id2 = v
end

function cls:get_cp_drop_id2( ... )
	-- body
	return self.__fields.cp_drop_id2
end

function cls:set_cp_drop_id3(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["cp_drop_id3"] = self.__ecol_updated["cp_drop_id3"] + 1
	if self.__ecol_updated["cp_drop_id3"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.cp_drop_id3 = v
end

function cls:get_cp_drop_id3( ... )
	-- body
	return self.__fields.cp_drop_id3
end

function cls:set_cp_fighting(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["cp_fighting"] = self.__ecol_updated["cp_fighting"] + 1
	if self.__ecol_updated["cp_fighting"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.cp_fighting = v
end

function cls:get_cp_fighting( ... )
	-- body
	return self.__fields.cp_fighting
end

function cls:set_lilian_level(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["lilian_level"] = self.__ecol_updated["lilian_level"] + 1
	if self.__ecol_updated["lilian_level"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.lilian_level = v
end

function cls:get_lilian_level( ... )
	-- body
	return self.__fields.lilian_level
end

function cls:set_lilian_exp(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["lilian_exp"] = self.__ecol_updated["lilian_exp"] + 1
	if self.__ecol_updated["lilian_exp"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.lilian_exp = v
end

function cls:get_lilian_exp( ... )
	-- body
	return self.__fields.lilian_exp
end

function cls:set_lilian_phy_power(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["lilian_phy_power"] = self.__ecol_updated["lilian_phy_power"] + 1
	if self.__ecol_updated["lilian_phy_power"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.lilian_phy_power = v
end

function cls:get_lilian_phy_power( ... )
	-- body
	return self.__fields.lilian_phy_power
end

function cls:set_purch_lilian_phy_power(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["purch_lilian_phy_power"] = self.__ecol_updated["purch_lilian_phy_power"] + 1
	if self.__ecol_updated["purch_lilian_phy_power"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.purch_lilian_phy_power = v
end

function cls:get_purch_lilian_phy_power( ... )
	-- body
	return self.__fields.purch_lilian_phy_power
end

function cls:set_ara_role_id1(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_role_id1"] = self.__ecol_updated["ara_role_id1"] + 1
	if self.__ecol_updated["ara_role_id1"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_role_id1 = v
end

function cls:get_ara_role_id1( ... )
	-- body
	return self.__fields.ara_role_id1
end

function cls:set_ara_role_id2(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_role_id2"] = self.__ecol_updated["ara_role_id2"] + 1
	if self.__ecol_updated["ara_role_id2"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_role_id2 = v
end

function cls:get_ara_role_id2( ... )
	-- body
	return self.__fields.ara_role_id2
end

function cls:set_ara_role_id3(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_role_id3"] = self.__ecol_updated["ara_role_id3"] + 1
	if self.__ecol_updated["ara_role_id3"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_role_id3 = v
end

function cls:get_ara_role_id3( ... )
	-- body
	return self.__fields.ara_role_id3
end

function cls:set_ara_win_tms(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_win_tms"] = self.__ecol_updated["ara_win_tms"] + 1
	if self.__ecol_updated["ara_win_tms"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_win_tms = v
end

function cls:get_ara_win_tms( ... )
	-- body
	return self.__fields.ara_win_tms
end

function cls:set_ara_lose_tms(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_lose_tms"] = self.__ecol_updated["ara_lose_tms"] + 1
	if self.__ecol_updated["ara_lose_tms"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_lose_tms = v
end

function cls:get_ara_lose_tms( ... )
	-- body
	return self.__fields.ara_lose_tms
end

function cls:set_ara_tie_tms(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_tie_tms"] = self.__ecol_updated["ara_tie_tms"] + 1
	if self.__ecol_updated["ara_tie_tms"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_tie_tms = v
end

function cls:get_ara_tie_tms( ... )
	-- body
	return self.__fields.ara_tie_tms
end

function cls:set_ara_clg_tms(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_clg_tms"] = self.__ecol_updated["ara_clg_tms"] + 1
	if self.__ecol_updated["ara_clg_tms"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_clg_tms = v
end

function cls:get_ara_clg_tms( ... )
	-- body
	return self.__fields.ara_clg_tms
end

function cls:set_ara_clg_cost_tms(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_clg_cost_tms"] = self.__ecol_updated["ara_clg_cost_tms"] + 1
	if self.__ecol_updated["ara_clg_cost_tms"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_clg_cost_tms = v
end

function cls:get_ara_clg_cost_tms( ... )
	-- body
	return self.__fields.ara_clg_cost_tms
end

function cls:set_ara_integral(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_integral"] = self.__ecol_updated["ara_integral"] + 1
	if self.__ecol_updated["ara_integral"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_integral = v
end

function cls:get_ara_integral( ... )
	-- body
	return self.__fields.ara_integral
end

function cls:set_ara_fighting(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_fighting"] = self.__ecol_updated["ara_fighting"] + 1
	if self.__ecol_updated["ara_fighting"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_fighting = v
end

function cls:get_ara_fighting( ... )
	-- body
	return self.__fields.ara_fighting
end

function cls:set_ara_interface(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_interface"] = self.__ecol_updated["ara_interface"] + 1
	if self.__ecol_updated["ara_interface"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_interface = v
end

function cls:get_ara_interface( ... )
	-- body
	return self.__fields.ara_interface
end

function cls:set_ara_rfh_cost_tms(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_rfh_cost_tms"] = self.__ecol_updated["ara_rfh_cost_tms"] + 1
	if self.__ecol_updated["ara_rfh_cost_tms"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_rfh_cost_tms = v
end

function cls:get_ara_rfh_cost_tms( ... )
	-- body
	return self.__fields.ara_rfh_cost_tms
end

function cls:set_ara_r1_sum_combat(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_r1_sum_combat"] = self.__ecol_updated["ara_r1_sum_combat"] + 1
	if self.__ecol_updated["ara_r1_sum_combat"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_r1_sum_combat = v
end

function cls:get_ara_r1_sum_combat( ... )
	-- body
	return self.__fields.ara_r1_sum_combat
end

function cls:set_ara_r1_sum_defense(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_r1_sum_defense"] = self.__ecol_updated["ara_r1_sum_defense"] + 1
	if self.__ecol_updated["ara_r1_sum_defense"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_r1_sum_defense = v
end

function cls:get_ara_r1_sum_defense( ... )
	-- body
	return self.__fields.ara_r1_sum_defense
end

function cls:set_ara_r1_sum_critical_hit(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_r1_sum_critical_hit"] = self.__ecol_updated["ara_r1_sum_critical_hit"] + 1
	if self.__ecol_updated["ara_r1_sum_critical_hit"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_r1_sum_critical_hit = v
end

function cls:get_ara_r1_sum_critical_hit( ... )
	-- body
	return self.__fields.ara_r1_sum_critical_hit
end

function cls:set_ara_r1_sum_king(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_r1_sum_king"] = self.__ecol_updated["ara_r1_sum_king"] + 1
	if self.__ecol_updated["ara_r1_sum_king"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_r1_sum_king = v
end

function cls:get_ara_r1_sum_king( ... )
	-- body
	return self.__fields.ara_r1_sum_king
end

function cls:set_ara_rfh_st(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_rfh_st"] = self.__ecol_updated["ara_rfh_st"] + 1
	if self.__ecol_updated["ara_rfh_st"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_rfh_st = v
end

function cls:get_ara_rfh_st( ... )
	-- body
	return self.__fields.ara_rfh_st
end

function cls:set_ara_rfh_cd(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_rfh_cd"] = self.__ecol_updated["ara_rfh_cd"] + 1
	if self.__ecol_updated["ara_rfh_cd"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_rfh_cd = v
end

function cls:get_ara_rfh_cd( ... )
	-- body
	return self.__fields.ara_rfh_cd
end

function cls:set_ara_rfh_cd_cost_tms(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_rfh_cd_cost_tms"] = self.__ecol_updated["ara_rfh_cd_cost_tms"] + 1
	if self.__ecol_updated["ara_rfh_cd_cost_tms"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_rfh_cd_cost_tms = v
end

function cls:get_ara_rfh_cd_cost_tms( ... )
	-- body
	return self.__fields.ara_rfh_cd_cost_tms
end

function cls:set_ara_clg_tms_rsttm(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_clg_tms_rsttm"] = self.__ecol_updated["ara_clg_tms_rsttm"] + 1
	if self.__ecol_updated["ara_clg_tms_rsttm"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_clg_tms_rsttm = v
end

function cls:get_ara_clg_tms_rsttm( ... )
	-- body
	return self.__fields.ara_clg_tms_rsttm
end

function cls:set_ara_clg_cost_rsttm(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_clg_cost_rsttm"] = self.__ecol_updated["ara_clg_cost_rsttm"] + 1
	if self.__ecol_updated["ara_clg_cost_rsttm"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_clg_cost_rsttm = v
end

function cls:get_ara_clg_cost_rsttm( ... )
	-- body
	return self.__fields.ara_clg_cost_rsttm
end

function cls:set_ara_integral_rsttm(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_integral_rsttm"] = self.__ecol_updated["ara_integral_rsttm"] + 1
	if self.__ecol_updated["ara_integral_rsttm"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_integral_rsttm = v
end

function cls:get_ara_integral_rsttm( ... )
	-- body
	return self.__fields.ara_integral_rsttm
end

function cls:set_draw_num(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["draw_num"] = self.__ecol_updated["draw_num"] + 1
	if self.__ecol_updated["draw_num"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.draw_num = v
end

function cls:get_draw_num( ... )
	-- body
	return self.__fields.draw_num
end

function cls:set_ara_r2_sum_combat(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_r2_sum_combat"] = self.__ecol_updated["ara_r2_sum_combat"] + 1
	if self.__ecol_updated["ara_r2_sum_combat"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_r2_sum_combat = v
end

function cls:get_ara_r2_sum_combat( ... )
	-- body
	return self.__fields.ara_r2_sum_combat
end

function cls:set_ara_r2_sum_defense(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_r2_sum_defense"] = self.__ecol_updated["ara_r2_sum_defense"] + 1
	if self.__ecol_updated["ara_r2_sum_defense"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_r2_sum_defense = v
end

function cls:get_ara_r2_sum_defense( ... )
	-- body
	return self.__fields.ara_r2_sum_defense
end

function cls:set_ara_r2_sum_critical_hit(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_r2_sum_critical_hit"] = self.__ecol_updated["ara_r2_sum_critical_hit"] + 1
	if self.__ecol_updated["ara_r2_sum_critical_hit"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_r2_sum_critical_hit = v
end

function cls:get_ara_r2_sum_critical_hit( ... )
	-- body
	return self.__fields.ara_r2_sum_critical_hit
end

function cls:set_ara_r2_sum_king(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_r2_sum_king"] = self.__ecol_updated["ara_r2_sum_king"] + 1
	if self.__ecol_updated["ara_r2_sum_king"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_r2_sum_king = v
end

function cls:get_ara_r2_sum_king( ... )
	-- body
	return self.__fields.ara_r2_sum_king
end

function cls:set_ara_r3_sum_combat(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_r3_sum_combat"] = self.__ecol_updated["ara_r3_sum_combat"] + 1
	if self.__ecol_updated["ara_r3_sum_combat"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_r3_sum_combat = v
end

function cls:get_ara_r3_sum_combat( ... )
	-- body
	return self.__fields.ara_r3_sum_combat
end

function cls:set_ara_r3_sum_defense(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_r3_sum_defense"] = self.__ecol_updated["ara_r3_sum_defense"] + 1
	if self.__ecol_updated["ara_r3_sum_defense"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_r3_sum_defense = v
end

function cls:get_ara_r3_sum_defense( ... )
	-- body
	return self.__fields.ara_r3_sum_defense
end

function cls:set_ara_r3_sum_critical_hit(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_r3_sum_critical_hit"] = self.__ecol_updated["ara_r3_sum_critical_hit"] + 1
	if self.__ecol_updated["ara_r3_sum_critical_hit"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_r3_sum_critical_hit = v
end

function cls:get_ara_r3_sum_critical_hit( ... )
	-- body
	return self.__fields.ara_r3_sum_critical_hit
end

function cls:set_ara_r3_sum_king(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ara_r3_sum_king"] = self.__ecol_updated["ara_r3_sum_king"] + 1
	if self.__ecol_updated["ara_r3_sum_king"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ara_r3_sum_king = v
end

function cls:get_ara_r3_sum_king( ... )
	-- body
	return self.__fields.ara_r3_sum_king
end

function cls:set_daily_recv_heart(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["daily_recv_heart"] = self.__ecol_updated["daily_recv_heart"] + 1
	if self.__ecol_updated["daily_recv_heart"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.daily_recv_heart = v
end

function cls:get_daily_recv_heart( ... )
	-- body
	return self.__fields.daily_recv_heart
end

function cls:set_friend_update_time(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["friend_update_time"] = self.__ecol_updated["friend_update_time"] + 1
	if self.__ecol_updated["friend_update_time"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.friend_update_time = v
end

function cls:get_friend_update_time( ... )
	-- body
	return self.__fields.friend_update_time
end


return cls
