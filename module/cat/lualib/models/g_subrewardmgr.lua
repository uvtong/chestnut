local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("g_subrewardmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_subreward"
	self.__head    = {
	csv_id = {
		pk = true,
		fk = false,
		cn = "csv_id",
		uq = false,
		t = "number",
	},
	propid = {
		pk = false,
		fk = false,
		cn = "propid",
		uq = false,
		t = "number",
	},
	propnum = {
		pk = false,
		fk = false,
		cn = "propnum",
		uq = false,
		t = "number",
	},
	proptype = {
		pk = false,
		fk = false,
		cn = "proptype",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["csv_id"]
	self.__head_ord[2] = self.__head["propid"]
	self.__head_ord[3] = self.__head["propnum"]
	self.__head_ord[4] = self.__head["proptype"]

	self.__pk      = "csv_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_subrewardentity"
	return self
end

return cls