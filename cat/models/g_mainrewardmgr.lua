local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("g_mainrewardmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_mainreward"
	self.__head    = {
	groupid = {
		pk = true,
		fk = false,
		cn = "groupid",
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
	probid = {
		pk = false,
		fk = false,
		cn = "probid",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["groupid"]
	self.__head_ord[2] = self.__head["csv_id"]
	self.__head_ord[3] = self.__head["probid"]

	self.__pk      = "groupid"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_mainrewardentity"
	return self
end

return cls