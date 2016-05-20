local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("g_equipment_enhancemgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_equipment_enhance"
	self.__head    = {
	id = {
		pk = true,
		fk = false,
		uq = false,
		t = "number",
	},
	g_csv_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	csv_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	name = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
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
	critical_hit_probability = {
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
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_equipment_enhanceentity"
	return self
end

return cls