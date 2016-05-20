local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("g_kungfumgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_kungfu"
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
	name = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
	csv_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	level = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	iconid = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	skill_descp = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
	skill_effect = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	type = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	harm_type = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	arise_probability = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	arise_count = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	arise_type = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	arise_param = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	attack_type = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	effect_percent = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	addition_effect_type = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	addition_prog = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	equip_buff_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	buff_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	prop_csv_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	prop_num = {
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
	self.__entity  = "g_kungfuentity"
	return self
end

return cls