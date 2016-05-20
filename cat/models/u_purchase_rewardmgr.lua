local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("u_purchase_rewardmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_purchase_reward"
	self.__head    = {
	id = {
		pk = true,
		fk = false,
		uq = false,
		t = "number",
	},
	user_id = {
		pk = false,
		fk = true,
		uq = false,
		t = "number",
	},
	distribute_time = {
		pk = false,
		fk = false,
		uq = false,
	},
	g_goods_csv_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	g_goods_num = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	c_type = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	c_recharge_vip = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	c_vip = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	collected = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	prop_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	csv_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
}

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_purchase_rewardentity"
	return self
end

return cls