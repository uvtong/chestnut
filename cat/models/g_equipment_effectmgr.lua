local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("g_equipment_effectmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_equipment_effect"
	self.__head    = {
	level = {
		pk = true,
		fk = false,
		cn = "level",
		uq = false,
		t = "number",
	},
	effect = {
		pk = false,
		fk = false,
		cn = "effect",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["level"]
	self.__head_ord[2] = self.__head["effect"]

	self.__pk      = "level"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_equipment_effectentity"
	return self
end

return cls