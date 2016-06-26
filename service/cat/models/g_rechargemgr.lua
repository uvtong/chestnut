local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("g_rechargemgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_recharge"
	self.__head    = {
	csv_id = {
		pk = true,
		fk = false,
		cn = "csv_id",
		uq = false,
		t = "number",
	},
	icon_id = {
		pk = false,
		fk = false,
		cn = "icon_id",
		uq = false,
		t = "number",
	},
	name = {
		pk = false,
		fk = false,
		cn = "name",
		uq = false,
		t = "string",
	},
	diamond = {
		pk = false,
		fk = false,
		cn = "diamond",
		uq = false,
		t = "number",
	},
	first = {
		pk = false,
		fk = false,
		cn = "first",
		uq = false,
		t = "number",
	},
	gift = {
		pk = false,
		fk = false,
		cn = "gift",
		uq = false,
		t = "number",
	},
	rmb = {
		pk = false,
		fk = false,
		cn = "rmb",
		uq = false,
		t = "number",
	},
	recharge_before = {
		pk = false,
		fk = false,
		cn = "recharge_before",
		uq = false,
		t = "string",
	},
	recharge_after = {
		pk = false,
		fk = false,
		cn = "recharge_after",
		uq = false,
		t = "string",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["csv_id"]
	self.__head_ord[2] = self.__head["icon_id"]
	self.__head_ord[3] = self.__head["name"]
	self.__head_ord[4] = self.__head["diamond"]
	self.__head_ord[5] = self.__head["first"]
	self.__head_ord[6] = self.__head["gift"]
	self.__head_ord[7] = self.__head["rmb"]
	self.__head_ord[8] = self.__head["recharge_before"]
	self.__head_ord[9] = self.__head["recharge_after"]

	self.__pk      = "csv_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_rechargeentity"
	return self
end

return cls