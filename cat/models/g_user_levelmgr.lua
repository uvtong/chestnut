local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("g_user_levelmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_user_level"
	self.__head    = {
	level = {
		pk = true,
		fk = false,
		cn = "level",
		uq = false,
		t = "number",
	},
	exp = {
		pk = false,
		fk = false,
		cn = "exp",
		uq = false,
		t = "number",
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
	skill = {
		pk = false,
		fk = false,
		cn = "skill",
		uq = false,
		t = "number",
	},
	gold_max = {
		pk = false,
		fk = false,
		cn = "gold_max",
		uq = false,
		t = "number",
	},
	exp_max = {
		pk = false,
		fk = false,
		cn = "exp_max",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["level"]
	self.__head_ord[2] = self.__head["exp"]
	self.__head_ord[3] = self.__head["combat"]
	self.__head_ord[4] = self.__head["defense"]
	self.__head_ord[5] = self.__head["critical_hit"]
	self.__head_ord[6] = self.__head["skill"]
	self.__head_ord[7] = self.__head["gold_max"]
	self.__head_ord[8] = self.__head["exp_max"]

	self.__pk      = "level"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_user_levelentity"
	return self
end

return cls