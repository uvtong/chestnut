local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
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
		cn = "id",
		uq = false,
		t = "number",
	},
	user_id = {
		pk = false,
		fk = true,
		cn = "user_id",
		uq = false,
		t = "number",
	},
	csv_id = {
		pk = false,
		fk = false,
		cn = "csv_id",
		uq = false,
		t = "number",
	},
	g_goods_csv_id = {
		pk = false,
		fk = false,
		cn = "g_goods_csv_id",
		uq = false,
		t = "number",
	},
	g_goods_num = {
		pk = false,
		fk = false,
		cn = "g_goods_num",
		uq = false,
		t = "number",
	},
	c_type = {
		pk = false,
		fk = false,
		cn = "c_type",
		uq = false,
		t = "number",
	},
	c_recharge_vip = {
		pk = false,
		fk = false,
		cn = "c_recharge_vip",
		uq = false,
		t = "number",
	},
	c_vip = {
		pk = false,
		fk = false,
		cn = "c_vip",
		uq = false,
		t = "number",
	},
	collected = {
		pk = false,
		fk = false,
		cn = "collected",
		uq = false,
		t = "number",
	},
	prop_id = {
		pk = false,
		fk = false,
		cn = "prop_id",
		uq = false,
		t = "number",
	},
	u_purchase_rewardcol = {
		pk = false,
		fk = false,
		cn = "u_purchase_rewardcol",
		uq = false,
		t = "string",
	},
	distribute_time = {
		pk = false,
		fk = false,
		cn = "distribute_time",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["user_id"]
	self.__head_ord[3] = self.__head["csv_id"]
	self.__head_ord[4] = self.__head["g_goods_csv_id"]
	self.__head_ord[5] = self.__head["g_goods_num"]
	self.__head_ord[6] = self.__head["c_type"]
	self.__head_ord[7] = self.__head["c_recharge_vip"]
	self.__head_ord[8] = self.__head["c_vip"]
	self.__head_ord[9] = self.__head["collected"]
	self.__head_ord[10] = self.__head["prop_id"]
	self.__head_ord[11] = self.__head["u_purchase_rewardcol"]
	self.__head_ord[12] = self.__head["distribute_time"]

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_purchase_rewardentity"
	return self
end

return cls