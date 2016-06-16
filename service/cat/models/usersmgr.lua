local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("usersmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "users"
	self.__head    = {
	csv_id = {
		pk = true,
		fk = false,
		cn = "csv_id",
		uq = false,
		t = "number",
	},
	uname = {
		pk = false,
		fk = false,
		cn = "uname",
		uq = false,
		t = "string",
	},
	uviplevel = {
		pk = false,
		fk = false,
		cn = "uviplevel",
		uq = false,
		t = "number",
	},
	config_sound = {
		pk = false,
		fk = false,
		cn = "config_sound",
		uq = false,
		t = "number",
	},
	config_music = {
		pk = false,
		fk = false,
		cn = "config_music",
		uq = false,
		t = "number",
	},
	avatar = {
		pk = false,
		fk = false,
		cn = "avatar",
		uq = false,
		t = "number",
	},
	sign = {
		pk = false,
		fk = false,
		cn = "sign",
		uq = false,
		t = "string",
	},
	c_role_id = {
		pk = false,
		fk = false,
		cn = "c_role_id",
		uq = false,
		t = "number",
	},
	ifonline = {
		pk = false,
		fk = false,
		cn = "ifonline",
		uq = false,
		t = "number",
	},
	level = {
		pk = false,
		fk = false,
		cn = "level",
		uq = false,
		t = "number",
	},
	combat = {
		pk = false,
		fk = false,
		cn = "combat",
		uq = false,
		t = "number",
	},
	defense = {
		pk = false,
		fk = false,
		cn = "defense",
		uq = false,
		t = "number",
	},
	critical_hit = {
		pk = false,
		fk = false,
		cn = "critical_hit",
		uq = false,
		t = "number",
	},
	blessing = {
		pk = false,
		fk = false,
		cn = "blessing",
		uq = false,
		t = "number",
	},
	permission = {
		pk = false,
		fk = false,
		cn = "permission",
		uq = false,
		t = "number",
	},
	modify_uname_count = {
		pk = false,
		fk = false,
		cn = "modify_uname_count",
		uq = false,
		t = "number",
	},
	onlinetime = {
		pk = false,
		fk = false,
		cn = "onlinetime",
		uq = false,
		t = "number",
	},
	iconid = {
		pk = false,
		fk = false,
		cn = "iconid",
		uq = false,
		t = "number",
	},
	is_valid = {
		pk = false,
		fk = false,
		cn = "is_valid",
		uq = false,
		t = "number",
	},
	recharge_rmb = {
		pk = false,
		fk = false,
		cn = "recharge_rmb",
		uq = false,
		t = "number",
	},
	recharge_diamond = {
		pk = false,
		fk = false,
		cn = "recharge_diamond",
		uq = false,
		t = "number",
	},
	uvip_progress = {
		pk = false,
		fk = false,
		cn = "uvip_progress",
		uq = false,
		t = "number",
	},
	checkin_num = {
		pk = false,
		fk = false,
		cn = "checkin_num",
		uq = false,
		t = "number",
	},
	checkin_reward_num = {
		pk = false,
		fk = false,
		cn = "checkin_reward_num",
		uq = false,
		t = "number",
	},
	exercise_level = {
		pk = false,
		fk = false,
		cn = "exercise_level",
		uq = false,
		t = "number",
	},
	cgold_level = {
		pk = false,
		fk = false,
		cn = "cgold_level",
		uq = false,
		t = "number",
	},
	gold_max = {
		pk = false,
		fk = false,
		cn = "gold_max",
		uq = false,
		t = "number",
	},
	exp_max = {
		pk = false,
		fk = false,
		cn = "exp_max",
		uq = false,
		t = "number",
	},
	equipment_enhance_success_rate_up_p = {
		pk = false,
		fk = false,
		cn = "equipment_enhance_success_rate_up_p",
		uq = false,
		t = "number",
	},
	store_refresh_count_max = {
		pk = false,
		fk = false,
		cn = "store_refresh_count_max",
		uq = false,
		t = "number",
	},
	prop_refresh = {
		pk = false,
		fk = false,
		cn = "prop_refresh",
		uq = false,
		t = "number",
	},
	arena_frozen_time = {
		pk = false,
		fk = false,
		cn = "arena_frozen_time",
		uq = false,
		t = "number",
	},
	purchase_hp_count = {
		pk = false,
		fk = false,
		cn = "purchase_hp_count",
		uq = false,
		t = "number",
	},
	gain_gold_up_p = {
		pk = false,
		fk = false,
		cn = "gain_gold_up_p",
		uq = false,
		t = "number",
	},
	gain_exp_up_p = {
		pk = false,
		fk = false,
		cn = "gain_exp_up_p",
		uq = false,
		t = "number",
	},
	purchase_hp_count_max = {
		pk = false,
		fk = false,
		cn = "purchase_hp_count_max",
		uq = false,
		t = "number",
	},
	SCHOOL_reset_count_max = {
		pk = false,
		fk = false,
		cn = "SCHOOL_reset_count_max",
		uq = false,
		t = "number",
	},
	SCHOOL_reset_count = {
		pk = false,
		fk = false,
		cn = "SCHOOL_reset_count",
		uq = false,
		t = "number",
	},
	signup_time = {
		pk = false,
		fk = false,
		cn = "signup_time",
		uq = false,
		t = "number",
	},
	pemail_csv_id = {
		pk = false,
		fk = false,
		cn = "pemail_csv_id",
		uq = false,
		t = "number",
	},
	take_diamonds = {
		pk = false,
		fk = false,
		cn = "take_diamonds",
		uq = false,
		t = "number",
	},
	draw_number = {
		pk = false,
		fk = false,
		cn = "draw_number",
		uq = false,
		t = "number",
	},
	ifxilian = {
		pk = false,
		fk = false,
		cn = "ifxilian",
		uq = false,
		t = "number",
	},
	cp_chapter = {
		pk = false,
		fk = false,
		cn = "cp_chapter",
		uq = false,
		t = "number",
	},
	cp_type = {
		pk = false,
		fk = false,
		cn = "cp_type",
		uq = false,
		t = "number",
	},
	cp_checkpoint = {
		pk = false,
		fk = false,
		cn = "cp_checkpoint",
		uq = false,
		t = "number",
	},
	cp_id = {
		pk = false,
		fk = false,
		cn = "cp_id",
		uq = false,
		t = "number",
	},
	cp_drop_id1 = {
		pk = false,
		fk = false,
		cn = "cp_drop_id1",
		uq = false,
		t = "number",
	},
	cp_drop_id2 = {
		pk = false,
		fk = false,
		cn = "cp_drop_id2",
		uq = false,
		t = "number",
	},
	cp_drop_id3 = {
		pk = false,
		fk = false,
		cn = "cp_drop_id3",
		uq = false,
		t = "number",
	},
	cp_fighting = {
		pk = false,
		fk = false,
		cn = "cp_fighting",
		uq = false,
		t = "number",
	},
	lilian_level = {
		pk = false,
		fk = false,
		cn = "lilian_level",
		uq = false,
		t = "number",
	},
	lilian_exp = {
		pk = false,
		fk = false,
		cn = "lilian_exp",
		uq = false,
		t = "number",
	},
	lilian_phy_power = {
		pk = false,
		fk = false,
		cn = "lilian_phy_power",
		uq = false,
		t = "number",
	},
	purch_lilian_phy_power = {
		pk = false,
		fk = false,
		cn = "purch_lilian_phy_power",
		uq = false,
		t = "number",
	},
	ara_role_id1 = {
		pk = false,
		fk = false,
		cn = "ara_role_id1",
		uq = false,
		t = "number",
	},
	ara_role_id2 = {
		pk = false,
		fk = false,
		cn = "ara_role_id2",
		uq = false,
		t = "number",
	},
	ara_role_id3 = {
		pk = false,
		fk = false,
		cn = "ara_role_id3",
		uq = false,
		t = "number",
	},
	ara_win_tms = {
		pk = false,
		fk = false,
		cn = "ara_win_tms",
		uq = false,
		t = "number",
	},
	ara_lose_tms = {
		pk = false,
		fk = false,
		cn = "ara_lose_tms",
		uq = false,
		t = "number",
	},
	ara_tie_tms = {
		pk = false,
		fk = false,
		cn = "ara_tie_tms",
		uq = false,
		t = "number",
	},
	ara_clg_tms = {
		pk = false,
		fk = false,
		cn = "ara_clg_tms",
		uq = false,
		t = "number",
	},
	ara_clg_cost_tms = {
		pk = false,
		fk = false,
		cn = "ara_clg_cost_tms",
		uq = false,
		t = "number",
	},
	ara_integral = {
		pk = false,
		fk = false,
		cn = "ara_integral",
		uq = false,
		t = "number",
	},
	ara_fighting = {
		pk = false,
		fk = false,
		cn = "ara_fighting",
		uq = false,
		t = "number",
	},
	ara_interface = {
		pk = false,
		fk = false,
		cn = "ara_interface",
		uq = false,
		t = "number",
	},
	ara_rfh_cost_tms = {
		pk = false,
		fk = false,
		cn = "ara_rfh_cost_tms",
		uq = false,
		t = "number",
	},
	ara_r1_sum_combat = {
		pk = false,
		fk = false,
		cn = "ara_r1_sum_combat",
		uq = false,
		t = "number",
	},
	ara_r1_sum_defense = {
		pk = false,
		fk = false,
		cn = "ara_r1_sum_defense",
		uq = false,
		t = "number",
	},
	ara_r1_sum_critical_hit = {
		pk = false,
		fk = false,
		cn = "ara_r1_sum_critical_hit",
		uq = false,
		t = "number",
	},
	ara_r1_sum_king = {
		pk = false,
		fk = false,
		cn = "ara_r1_sum_king",
		uq = false,
		t = "number",
	},
	ara_rfh_st = {
		pk = false,
		fk = false,
		cn = "ara_rfh_st",
		uq = false,
		t = "number",
	},
	ara_rfh_cd = {
		pk = false,
		fk = false,
		cn = "ara_rfh_cd",
		uq = false,
		t = "number",
	},
	ara_rfh_cd_cost_tms = {
		pk = false,
		fk = false,
		cn = "ara_rfh_cd_cost_tms",
		uq = false,
		t = "number",
	},
	ara_clg_tms_rsttm = {
		pk = false,
		fk = false,
		cn = "ara_clg_tms_rsttm",
		uq = false,
		t = "number",
	},
	ara_clg_cost_rsttm = {
		pk = false,
		fk = false,
		cn = "ara_clg_cost_rsttm",
		uq = false,
		t = "number",
	},
	ara_integral_rsttm = {
		pk = false,
		fk = false,
		cn = "ara_integral_rsttm",
		uq = false,
		t = "number",
	},
	draw_num = {
		pk = false,
		fk = false,
		cn = "draw_num",
		uq = false,
		t = "number",
	},
	ara_r2_sum_combat = {
		pk = false,
		fk = false,
		cn = "ara_r2_sum_combat",
		uq = false,
		t = "number",
	},
	ara_r2_sum_defense = {
		pk = false,
		fk = false,
		cn = "ara_r2_sum_defense",
		uq = false,
		t = "number",
	},
	ara_r2_sum_critical_hit = {
		pk = false,
		fk = false,
		cn = "ara_r2_sum_critical_hit",
		uq = false,
		t = "number",
	},
	ara_r2_sum_king = {
		pk = false,
		fk = false,
		cn = "ara_r2_sum_king",
		uq = false,
		t = "number",
	},
	ara_r3_sum_combat = {
		pk = false,
		fk = false,
		cn = "ara_r3_sum_combat",
		uq = false,
		t = "number",
	},
	ara_r3_sum_defense = {
		pk = false,
		fk = false,
		cn = "ara_r3_sum_defense",
		uq = false,
		t = "number",
	},
	ara_r3_sum_critical_hit = {
		pk = false,
		fk = false,
		cn = "ara_r3_sum_critical_hit",
		uq = false,
		t = "number",
	},
	ara_r3_sum_king = {
		pk = false,
		fk = false,
		cn = "ara_r3_sum_king",
		uq = false,
		t = "number",
	},
	daily_recv_heart = {
		pk = false,
		fk = false,
		cn = "daily_recv_heart",
		uq = false,
		t = "number",
	},
	friend_update_time = {
		pk = false,
		fk = false,
		cn = "friend_update_time",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["csv_id"]
	self.__head_ord[2] = self.__head["uname"]
	self.__head_ord[3] = self.__head["uviplevel"]
	self.__head_ord[4] = self.__head["config_sound"]
	self.__head_ord[5] = self.__head["config_music"]
	self.__head_ord[6] = self.__head["avatar"]
	self.__head_ord[7] = self.__head["sign"]
	self.__head_ord[8] = self.__head["c_role_id"]
	self.__head_ord[9] = self.__head["ifonline"]
	self.__head_ord[10] = self.__head["level"]
	self.__head_ord[11] = self.__head["combat"]
	self.__head_ord[12] = self.__head["defense"]
	self.__head_ord[13] = self.__head["critical_hit"]
	self.__head_ord[14] = self.__head["blessing"]
	self.__head_ord[15] = self.__head["permission"]
	self.__head_ord[16] = self.__head["modify_uname_count"]
	self.__head_ord[17] = self.__head["onlinetime"]
	self.__head_ord[18] = self.__head["iconid"]
	self.__head_ord[19] = self.__head["is_valid"]
	self.__head_ord[20] = self.__head["recharge_rmb"]
	self.__head_ord[21] = self.__head["recharge_diamond"]
	self.__head_ord[22] = self.__head["uvip_progress"]
	self.__head_ord[23] = self.__head["checkin_num"]
	self.__head_ord[24] = self.__head["checkin_reward_num"]
	self.__head_ord[25] = self.__head["exercise_level"]
	self.__head_ord[26] = self.__head["cgold_level"]
	self.__head_ord[27] = self.__head["gold_max"]
	self.__head_ord[28] = self.__head["exp_max"]
	self.__head_ord[29] = self.__head["equipment_enhance_success_rate_up_p"]
	self.__head_ord[30] = self.__head["store_refresh_count_max"]
	self.__head_ord[31] = self.__head["prop_refresh"]
	self.__head_ord[32] = self.__head["arena_frozen_time"]
	self.__head_ord[33] = self.__head["purchase_hp_count"]
	self.__head_ord[34] = self.__head["gain_gold_up_p"]
	self.__head_ord[35] = self.__head["gain_exp_up_p"]
	self.__head_ord[36] = self.__head["purchase_hp_count_max"]
	self.__head_ord[37] = self.__head["SCHOOL_reset_count_max"]
	self.__head_ord[38] = self.__head["SCHOOL_reset_count"]
	self.__head_ord[39] = self.__head["signup_time"]
	self.__head_ord[40] = self.__head["pemail_csv_id"]
	self.__head_ord[41] = self.__head["take_diamonds"]
	self.__head_ord[42] = self.__head["draw_number"]
	self.__head_ord[43] = self.__head["ifxilian"]
	self.__head_ord[44] = self.__head["cp_chapter"]
	self.__head_ord[45] = self.__head["cp_type"]
	self.__head_ord[46] = self.__head["cp_checkpoint"]
	self.__head_ord[47] = self.__head["cp_id"]
	self.__head_ord[48] = self.__head["cp_drop_id1"]
	self.__head_ord[49] = self.__head["cp_drop_id2"]
	self.__head_ord[50] = self.__head["cp_drop_id3"]
	self.__head_ord[51] = self.__head["cp_fighting"]
	self.__head_ord[52] = self.__head["lilian_level"]
	self.__head_ord[53] = self.__head["lilian_exp"]
	self.__head_ord[54] = self.__head["lilian_phy_power"]
	self.__head_ord[55] = self.__head["purch_lilian_phy_power"]
	self.__head_ord[56] = self.__head["ara_role_id1"]
	self.__head_ord[57] = self.__head["ara_role_id2"]
	self.__head_ord[58] = self.__head["ara_role_id3"]
	self.__head_ord[59] = self.__head["ara_win_tms"]
	self.__head_ord[60] = self.__head["ara_lose_tms"]
	self.__head_ord[61] = self.__head["ara_tie_tms"]
	self.__head_ord[62] = self.__head["ara_clg_tms"]
	self.__head_ord[63] = self.__head["ara_clg_cost_tms"]
	self.__head_ord[64] = self.__head["ara_integral"]
	self.__head_ord[65] = self.__head["ara_fighting"]
	self.__head_ord[66] = self.__head["ara_interface"]
	self.__head_ord[67] = self.__head["ara_rfh_cost_tms"]
	self.__head_ord[68] = self.__head["ara_r1_sum_combat"]
	self.__head_ord[69] = self.__head["ara_r1_sum_defense"]
	self.__head_ord[70] = self.__head["ara_r1_sum_critical_hit"]
	self.__head_ord[71] = self.__head["ara_r1_sum_king"]
	self.__head_ord[72] = self.__head["ara_rfh_st"]
	self.__head_ord[73] = self.__head["ara_rfh_cd"]
	self.__head_ord[74] = self.__head["ara_rfh_cd_cost_tms"]
	self.__head_ord[75] = self.__head["ara_clg_tms_rsttm"]
	self.__head_ord[76] = self.__head["ara_clg_cost_rsttm"]
	self.__head_ord[77] = self.__head["ara_integral_rsttm"]
	self.__head_ord[78] = self.__head["draw_num"]
	self.__head_ord[79] = self.__head["ara_r2_sum_combat"]
	self.__head_ord[80] = self.__head["ara_r2_sum_defense"]
	self.__head_ord[81] = self.__head["ara_r2_sum_critical_hit"]
	self.__head_ord[82] = self.__head["ara_r2_sum_king"]
	self.__head_ord[83] = self.__head["ara_r3_sum_combat"]
	self.__head_ord[84] = self.__head["ara_r3_sum_defense"]
	self.__head_ord[85] = self.__head["ara_r3_sum_critical_hit"]
	self.__head_ord[86] = self.__head["ara_r3_sum_king"]
	self.__head_ord[87] = self.__head["daily_recv_heart"]
	self.__head_ord[88] = self.__head["friend_update_time"]

	self.__pk      = "csv_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "usersentity"
	return self
end

return cls