local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("g_property_pool_secondmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_property_pool_second"
	self.__head    = {
	csv_id = {
		pk = true,
		fk = false,
		cn = "csv_id",
		uq = false,
		t = "number",
	},
	property_pool_id = {
		pk = false,
		fk = false,
		cn = "property_pool_id",
		uq = false,
		t = "number",
	},
	probability = {
		pk = false,
		fk = false,
		cn = "probability",
		uq = false,
		t = "number",
	},
	property_id = {
		pk = false,
		fk = false,
		cn = "property_id",
		uq = false,
		t = "number",
	},
	value = {
		pk = false,
		fk = false,
		cn = "value",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["csv_id"]
	self.__head_ord[2] = self.__head["property_pool_id"]
	self.__head_ord[3] = self.__head["probability"]
	self.__head_ord[4] = self.__head["property_id"]
	self.__head_ord[5] = self.__head["value"]

	self.__pk      = "csv_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_property_pool_secondentity"
	return self
end

return cls