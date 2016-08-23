local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("g_goodsmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_goods"
	self.__head    = {
	csv_id = {
		pk = true,
		fk = false,
		cn = "csv_id",
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
	g_prop_csv_id = {
		pk = false,
		fk = false,
		cn = "g_prop_csv_id",
		uq = false,
		t = "number",
	},
	g_prop_num = {
		pk = false,
		fk = false,
		cn = "g_prop_num",
		uq = false,
		t = "number",
	},
	inventory_init = {
		pk = false,
		fk = false,
		cn = "inventory_init",
		uq = false,
		t = "number",
	},
	cd = {
		pk = false,
		fk = false,
		cn = "cd",
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
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["csv_id"]
	self.__head_ord[2] = self.__head["currency_type"]
	self.__head_ord[3] = self.__head["currency_num"]
	self.__head_ord[4] = self.__head["g_prop_csv_id"]
	self.__head_ord[5] = self.__head["g_prop_num"]
	self.__head_ord[6] = self.__head["inventory_init"]
	self.__head_ord[7] = self.__head["cd"]
	self.__head_ord[8] = self.__head["icon_id"]

	self.__pk      = "csv_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_goodsentity"
	return self
end

return cls