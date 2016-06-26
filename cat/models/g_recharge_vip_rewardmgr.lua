local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("g_recharge_vip_rewardmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_recharge_vip_reward"
	self.__head    = {
	vip = {
		pk = true,
		fk = false,
		cn = "vip",
		uq = false,
		t = "number",
	},
	diamond = {
		pk = false,
		fk = false,
		cn = "diamond",
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
	gold_max_up_p = {
		pk = false,
		fk = false,
		cn = "gold_max_up_p",
		uq = false,
		t = "number",
	},
	exp_max_up_p = {
		pk = false,
		fk = false,
		cn = "exp_max_up_p",
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
	prop_refresh_reduction_p = {
		pk = false,
		fk = false,
		cn = "prop_refresh_reduction_p",
		uq = false,
		t = "number",
	},
	arena_frozen_time_reduction_p = {
		pk = false,
		fk = false,
		cn = "arena_frozen_time_reduction_p",
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
	rewared = {
		pk = false,
		fk = false,
		cn = "rewared",
		uq = false,
		t = "string",
	},
	store_refresh_count_max = {
		pk = false,
		fk = false,
		cn = "store_refresh_count_max",
		uq = false,
		t = "number",
	},
	purchasable_gift = {
		pk = false,
		fk = false,
		cn = "purchasable_gift",
		uq = false,
		t = "string",
	},
	marked_diamond = {
		pk = false,
		fk = false,
		cn = "marked_diamond",
		uq = false,
		t = "number",
	},
	purchasable_diamond = {
		pk = false,
		fk = false,
		cn = "purchasable_diamond",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["vip"]
	self.__head_ord[2] = self.__head["diamond"]
	self.__head_ord[3] = self.__head["gain_gold_up_p"]
	self.__head_ord[4] = self.__head["gain_exp_up_p"]
	self.__head_ord[5] = self.__head["gold_max_up_p"]
	self.__head_ord[6] = self.__head["exp_max_up_p"]
	self.__head_ord[7] = self.__head["equipment_enhance_success_rate_up_p"]
	self.__head_ord[8] = self.__head["prop_refresh_reduction_p"]
	self.__head_ord[9] = self.__head["arena_frozen_time_reduction_p"]
	self.__head_ord[10] = self.__head["purchase_hp_count_max"]
	self.__head_ord[11] = self.__head["SCHOOL_reset_count_max"]
	self.__head_ord[12] = self.__head["rewared"]
	self.__head_ord[13] = self.__head["store_refresh_count_max"]
	self.__head_ord[14] = self.__head["purchasable_gift"]
	self.__head_ord[15] = self.__head["marked_diamond"]
	self.__head_ord[16] = self.__head["purchasable_diamond"]

	self.__pk      = "vip"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_recharge_vip_rewardentity"
	return self
end

return cls