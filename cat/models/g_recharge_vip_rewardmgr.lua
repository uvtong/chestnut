local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
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
	id = {
		pk = true,
		fk = false,
		uq = false,
		t = "number",
	},
	vip = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	diamond = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	gain_gold_up_p = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	gain_exp_up_p = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	gold_max_up_p = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	exp_max_up_p = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	equipment_enhance_success_rate_up_p = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	prop_refresh_reduction_p = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	arena_frozen_time_reduction_p = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	purchase_hp_count_max = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	SCHOOL_reset_count_max = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	rewared = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
	store_refresh_count_max = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	purchasable_gift = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
	marked_diamond = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	purchasable_diamond = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
}

	self.__pk      = "id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_recharge_vip_rewardentity"
	return self
end

return cls