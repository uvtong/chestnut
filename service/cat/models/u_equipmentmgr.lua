local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("u_equipmentmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_equipment"
	self.__head    = {
	id = {
		pk = true,
		fk = false,
		cn = "id",
		uq = false,
		t = "number",
	},
	user_id = {
		pk = false,
		fk = true,
		cn = "user_id",
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
	level = {
		pk = false,
		fk = false,
		cn = "level",
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
	king = {
		pk = false,
		fk = false,
		cn = "king",
		uq = false,
		t = "number",
	},
	critical_hit_probability = {
		pk = false,
		fk = false,
		cn = "critical_hit_probability",
		uq = false,
		t = "number",
	},
	combat_probability = {
		pk = false,
		fk = false,
		cn = "combat_probability",
		uq = false,
		t = "number",
	},
	defense_probability = {
		pk = false,
		fk = false,
		cn = "defense_probability",
		uq = false,
		t = "number",
	},
	king_probability = {
		pk = false,
		fk = false,
		cn = "king_probability",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["user_id"]
	self.__head_ord[3] = self.__head["csv_id"]
	self.__head_ord[4] = self.__head["level"]
	self.__head_ord[5] = self.__head["combat"]
	self.__head_ord[6] = self.__head["defense"]
	self.__head_ord[7] = self.__head["critical_hit"]
	self.__head_ord[8] = self.__head["king"]
	self.__head_ord[9] = self.__head["critical_hit_probability"]
	self.__head_ord[10] = self.__head["combat_probability"]
	self.__head_ord[11] = self.__head["defense_probability"]
	self.__head_ord[12] = self.__head["king_probability"]

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_equipmententity"
	return self
end

return cls