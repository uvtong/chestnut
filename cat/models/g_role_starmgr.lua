local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
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
	star = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	us_prop_csv_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	us_prop_num = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	sharp = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	skill_csv_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	gather_buffer_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	battle_buffer_id = {
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
	self.__entity  = "g_role_starentity"
	return self
end

return cls