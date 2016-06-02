local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("Sheet1mgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "Sheet1"
	self.__head    = {
	csv_id = {
		pk = false,
		fk = false,
		cn = "csv_id",
		uq = false,
		t = "string",
	},
	purchase_cost = {
		pk = false,
		fk = false,
		cn = "purchase_cost",
		uq = false,
		t = "string",
	},
	list_refresh_cost = {
		pk = false,
		fk = false,
		cn = "list_refresh_cost",
		uq = false,
		t = "string",
	},
	list_cd_refresh_cost = {
		pk = false,
		fk = false,
		cn = "list_cd_refresh_cost",
		uq = false,
		t = "string",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["csv_id"]
	self.__head_ord[2] = self.__head["purchase_cost"]
	self.__head_ord[3] = self.__head["list_refresh_cost"]
	self.__head_ord[4] = self.__head["list_cd_refresh_cost"]

	self.__pk      = ""
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "Sheet1entity"
	return self
end

return cls