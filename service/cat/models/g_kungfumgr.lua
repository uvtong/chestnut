local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
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
	g_csv_id = {
		pk = true,
		fk = false,
		cn = "g_csv_id",
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
	iconid = {
		pk = false,
		fk = false,
		cn = "iconid",
		uq = false,
		t = "number",
	},
	skill_descp = {
		pk = false,
		fk = false,
		cn = "skill_descp",
		uq = false,
		t = "string",
	},
	skill_effect = {
		pk = false,
		fk = false,
		cn = "skill_effect",
		uq = false,
		t = "number",
	},
	type = {
		pk = false,
		fk = false,
		cn = "type",
		uq = false,
		t = "number",
	},
	harm_type = {
		pk = false,
		fk = false,
		cn = "harm_type",
		uq = false,
		t = "number",
	},
	arise_probability = {
		pk = false,
		fk = false,
		cn = "arise_probability",
		uq = false,
		t = "number",
	},
	arise_count = {
		pk = false,
		fk = false,
		cn = "arise_count",
		uq = false,
		t = "number",
	},
	arise_type = {
		pk = false,
		fk = false,
		cn = "arise_type",
		uq = false,
		t = "number",
	},
	arise_param = {
		pk = false,
		fk = false,
		cn = "arise_param",
		uq = false,
		t = "number",
	},
	attack_type = {
		pk = false,
		fk = false,
		cn = "attack_type",
		uq = false,
		t = "number",
	},
	effect_percent = {
		pk = false,
		fk = false,
		cn = "effect_percent",
		uq = false,
		t = "number",
	},
	addition_effect_type = {
		pk = false,
		fk = false,
		cn = "addition_effect_type",
		uq = false,
		t = "number",
	},
	addition_prog = {
		pk = false,
		fk = false,
		cn = "addition_prog",
		uq = false,
		t = "number",
	},
	equip_buff_id = {
		pk = false,
		fk = false,
		cn = "equip_buff_id",
		uq = false,
		t = "number",
	},
	buff_id = {
		pk = false,
		fk = false,
		cn = "buff_id",
		uq = false,
		t = "number",
	},
	prop_csv_id = {
		pk = false,
		fk = false,
		cn = "prop_csv_id",
		uq = false,
		t = "number",
	},
	prop_num = {
		pk = false,
		fk = false,
		cn = "prop_num",
		uq = false,
		t = "number",
	},
	currency_type = {
		pk = false,
		fk = false,
		cn = "currency_type",
		uq = false,
		t = "number",
	},
	currency_num = {
		pk = false,
		fk = false,
		cn = "currency_num",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["g_csv_id"]
	self.__head_ord[2] = self.__head["name"]
	self.__head_ord[3] = self.__head["csv_id"]
	self.__head_ord[4] = self.__head["level"]
	self.__head_ord[5] = self.__head["iconid"]
	self.__head_ord[6] = self.__head["skill_descp"]
	self.__head_ord[7] = self.__head["skill_effect"]
	self.__head_ord[8] = self.__head["type"]
	self.__head_ord[9] = self.__head["harm_type"]
	self.__head_ord[10] = self.__head["arise_probability"]
	self.__head_ord[11] = self.__head["arise_count"]
	self.__head_ord[12] = self.__head["arise_type"]
	self.__head_ord[13] = self.__head["arise_param"]
	self.__head_ord[14] = self.__head["attack_type"]
	self.__head_ord[15] = self.__head["effect_percent"]
	self.__head_ord[16] = self.__head["addition_effect_type"]
	self.__head_ord[17] = self.__head["addition_prog"]
	self.__head_ord[18] = self.__head["equip_buff_id"]
	self.__head_ord[19] = self.__head["buff_id"]
	self.__head_ord[20] = self.__head["prop_csv_id"]
	self.__head_ord[21] = self.__head["prop_num"]
	self.__head_ord[22] = self.__head["currency_type"]
	self.__head_ord[23] = self.__head["currency_num"]

	self.__pk      = "g_csv_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_kungfuentity"
	return self
end

return cls