local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("g_role_starmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_role_star"
	self.__head    = {
	g_csv_id = {
		pk = true,
		fk = false,
		cn = "g_csv_id",
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
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head[g_csv_id]
	self.__head_ord[2] = self.__head[csv_id]
	self.__head_ord[3] = self.__head[name]
	self.__head_ord[4] = self.__head[star]
	self.__head_ord[5] = self.__head[us_prop_csv_id]
	self.__head_ord[6] = self.__head[us_prop_num]
	self.__head_ord[7] = self.__head[sharp]
	self.__head_ord[8] = self.__head[skill_csv_id]
	self.__head_ord[9] = self.__head[gather_buffer_id]
	self.__head_ord[10] = self.__head[battle_buffer_id]

	self.__pk      = "g_csv_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_role_starentity"
	return self
end

return cls