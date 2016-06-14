local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("g_monstermgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_monster"
	self.__head    = {
	csv_id = {
		pk = true,
		fk = false,
		cn = "csv_id",
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
	combat = {
		pk = false,
		fk = false,
		cn = "combat",
		uq = false,
		t = "number",
	},
	defense = {
		pk = false,
		fk = false,
		cn = "defense",
		uq = false,
		t = "number",
	},
	critical_hit = {
		pk = false,
		fk = false,
		cn = "critical_hit",
		uq = false,
		t = "number",
	},
	blessing = {
		pk = false,
		fk = false,
		cn = "blessing",
		uq = false,
		t = "number",
	},
	quanfaid = {
		pk = false,
		fk = false,
		cn = "quanfaid",
		uq = false,
		t = "string",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["csv_id"]
	self.__head_ord[2] = self.__head["name"]
	self.__head_ord[3] = self.__head["combat"]
	self.__head_ord[4] = self.__head["defense"]
	self.__head_ord[5] = self.__head["critical_hit"]
	self.__head_ord[6] = self.__head["blessing"]
	self.__head_ord[7] = self.__head["quanfaid"]

	self.__pk      = "csv_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_monsterentity"
	return self
end

return cls