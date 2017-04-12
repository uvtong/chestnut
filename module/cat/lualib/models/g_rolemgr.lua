local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("g_rolemgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_role"
	self.__head    = {
	csv_id = {
		pk = true,
		fk = false,
		cn = "csv_id",
		uq = false,
		t = "number",
	},
	star = {
		pk = false,
		fk = false,
		cn = "star",
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
	us_prop_csv_id = {
		pk = false,
		fk = false,
		cn = "us_prop_csv_id",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["csv_id"]
	self.__head_ord[2] = self.__head["star"]
	self.__head_ord[3] = self.__head["name"]
	self.__head_ord[4] = self.__head["us_prop_csv_id"]

	self.__pk      = "csv_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_roleentity"
	return self
end

return cls