local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("u_rolemgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_role"
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
	name = {
		pk = false,
		fk = false,
		cn = "name",
		uq = false,
		t = "string",
	},
	star = {
		pk = false,
		fk = false,
		cn = "star",
		uq = false,
		t = "number",
	},
	us_prop_csv_id = {
		pk = false,
		fk = false,
		cn = "us_prop_csv_id",
		uq = false,
		t = "number",
	},
	us_prop_num = {
		pk = false,
		fk = false,
		cn = "us_prop_num",
		uq = false,
		t = "number",
	},
	sharp = {
		pk = false,
		fk = false,
		cn = "sharp",
		uq = false,
		t = "number",
	},
	skill_csv_id = {
		pk = false,
		fk = false,
		cn = "skill_csv_id",
		uq = false,
		t = "number",
	},
	gather_buffer_id = {
		pk = false,
		fk = false,
		cn = "gather_buffer_id",
		uq = false,
		t = "number",
	},
	battle_buffer_id = {
		pk = false,
		fk = false,
		cn = "battle_buffer_id",
		uq = false,
		t = "number",
	},
	k_csv_id1 = {
		pk = false,
		fk = false,
		cn = "k_csv_id1",
		uq = false,
		t = "number",
	},
	k_csv_id2 = {
		pk = false,
		fk = false,
		cn = "k_csv_id2",
		uq = false,
		t = "number",
	},
	k_csv_id3 = {
		pk = false,
		fk = false,
		cn = "k_csv_id3",
		uq = false,
		t = "number",
	},
	k_csv_id4 = {
		pk = false,
		fk = false,
		cn = "k_csv_id4",
		uq = false,
		t = "number",
	},
	k_csv_id5 = {
		pk = false,
		fk = false,
		cn = "k_csv_id5",
		uq = false,
		t = "number",
	},
	k_csv_id6 = {
		pk = false,
		fk = false,
		cn = "k_csv_id6",
		uq = false,
		t = "number",
	},
	k_csv_id7 = {
		pk = false,
		fk = false,
		cn = "k_csv_id7",
		uq = false,
		t = "number",
	},
	property_id1 = {
		pk = false,
		fk = false,
		cn = "property_id1",
		uq = false,
		t = "number",
	},
	value1 = {
		pk = false,
		fk = false,
		cn = "value1",
		uq = false,
		t = "number",
	},
	property_id2 = {
		pk = false,
		fk = false,
		cn = "property_id2",
		uq = false,
		t = "number",
	},
	value2 = {
		pk = false,
		fk = false,
		cn = "value2",
		uq = false,
		t = "number",
	},
	property_id3 = {
		pk = false,
		fk = false,
		cn = "property_id3",
		uq = false,
		t = "number",
	},
	value3 = {
		pk = false,
		fk = false,
		cn = "value3",
		uq = false,
		t = "number",
	},
	property_id4 = {
		pk = false,
		fk = false,
		cn = "property_id4",
		uq = false,
		t = "number",
	},
	value4 = {
		pk = false,
		fk = false,
		cn = "value4",
		uq = false,
		t = "number",
	},
	property_id5 = {
		pk = false,
		fk = false,
		cn = "property_id5",
		uq = false,
		t = "number",
	},
	value5 = {
		pk = false,
		fk = false,
		cn = "value5",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["user_id"]
	self.__head_ord[3] = self.__head["csv_id"]
	self.__head_ord[4] = self.__head["name"]
	self.__head_ord[5] = self.__head["star"]
	self.__head_ord[6] = self.__head["us_prop_csv_id"]
	self.__head_ord[7] = self.__head["us_prop_num"]
	self.__head_ord[8] = self.__head["sharp"]
	self.__head_ord[9] = self.__head["skill_csv_id"]
	self.__head_ord[10] = self.__head["gather_buffer_id"]
	self.__head_ord[11] = self.__head["battle_buffer_id"]
	self.__head_ord[12] = self.__head["k_csv_id1"]
	self.__head_ord[13] = self.__head["k_csv_id2"]
	self.__head_ord[14] = self.__head["k_csv_id3"]
	self.__head_ord[15] = self.__head["k_csv_id4"]
	self.__head_ord[16] = self.__head["k_csv_id5"]
	self.__head_ord[17] = self.__head["k_csv_id6"]
	self.__head_ord[18] = self.__head["k_csv_id7"]
	self.__head_ord[19] = self.__head["property_id1"]
	self.__head_ord[20] = self.__head["value1"]
	self.__head_ord[21] = self.__head["property_id2"]
	self.__head_ord[22] = self.__head["value2"]
	self.__head_ord[23] = self.__head["property_id3"]
	self.__head_ord[24] = self.__head["value3"]
	self.__head_ord[25] = self.__head["property_id4"]
	self.__head_ord[26] = self.__head["value4"]
	self.__head_ord[27] = self.__head["property_id5"]
	self.__head_ord[28] = self.__head["value5"]

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_roleentity"
	return self
end

return cls