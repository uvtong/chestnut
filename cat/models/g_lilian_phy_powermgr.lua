local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("g_lilian_phy_powermgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_lilian_phy_power"
	self.__head    = {
	csv_id = {
		pk = true,
		fk = false,
		cn = "csv_id",
		uq = false,
		t = "number",
	},
	dioment = {
		pk = false,
		fk = false,
		cn = "dioment",
		uq = false,
		t = "number",
	},
	reset_quanguan_dioment = {
		pk = false,
		fk = false,
		cn = "reset_quanguan_dioment",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["csv_id"]
	self.__head_ord[2] = self.__head["dioment"]
	self.__head_ord[3] = self.__head["reset_quanguan_dioment"]

	self.__pk      = "csv_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_lilian_phy_powerentity"
	return self
end

return cls