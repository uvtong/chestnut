local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("u_recharge_vip_rewardmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_recharge_vip_reward"
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
	vip = {
		pk = false,
		fk = false,
		cn = "vip",
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
	purchased = {
		pk = false,
		fk = false,
		cn = "purchased",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["user_id"]
	self.__head_ord[3] = self.__head["vip"]
	self.__head_ord[4] = self.__head["collected"]
	self.__head_ord[5] = self.__head["purchased"]

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_recharge_vip_rewardentity"
	return self
end

return cls