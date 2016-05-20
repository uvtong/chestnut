local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
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
		uq = false,
		t = "number",
	},
	user_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	csv_id = {
		pk = false,
		fk = true,
		uq = false,
		t = "number",
	},
	level = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	combat = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	defense = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	critical_hit = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	king = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	critical_hit_probability = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	combat_probability = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	defense_probability = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	king_probability = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	enhance_success_rate = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	currency_type = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	currency_num = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
}

	self.__pk      = "id"
	self.__fk      = "csv_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_equipmententity"
	return self
end

return cls