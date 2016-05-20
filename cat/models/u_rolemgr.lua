local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
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
		uq = false,
		t = "number",
	},
	user_id = {
		pk = false,
		fk = true,
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
	k_csv_id1 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	k_csv_id2 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	k_csv_id3 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	k_csv_id4 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	k_csv_id5 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	k_csv_id6 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	k_csv_id7 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	property_id1 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	value1 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	property_id2 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	value2 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	property_id3 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	value3 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	property_id4 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	value4 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	property_id5 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	value5 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
}

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_roleentity"
	return self
end

return cls