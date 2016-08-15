local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("u_purchase_goodsmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_purchase_goods"
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
	num = {
		pk = false,
		fk = false,
		cn = "num",
		uq = false,
		t = "number",
	},
	currency_type = {
		pk = false,
		fk = false,
		cn = "currency_type",
		uq = false,
		t = "number",
	},
	currency_num = {
		pk = false,
		fk = false,
		cn = "currency_num",
		uq = false,
		t = "number",
	},
	purchase_time = {
		pk = false,
		fk = false,
		cn = "purchase_time",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["user_id"]
	self.__head_ord[3] = self.__head["csv_id"]
	self.__head_ord[4] = self.__head["num"]
	self.__head_ord[5] = self.__head["currency_type"]
	self.__head_ord[6] = self.__head["currency_num"]
	self.__head_ord[7] = self.__head["purchase_time"]

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_purchase_goodsentity"
	return self
end

return cls