local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("g_goods_refresh_costmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_goods_refresh_cost"
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
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["csv_id"]
	self.__head_ord[2] = self.__head["currency_type"]
	self.__head_ord[3] = self.__head["currency_num"]

	self.__pk      = "csv_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_goods_refresh_costentity"
	return self
end

return cls