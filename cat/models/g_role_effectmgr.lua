local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("g_role_effectmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_role_effect"
	self.__head    = {
	id = {
		pk = true,
		fk = false,
		uq = false,
		t = "number",
	},
	buffer_id = {
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
	property_id6 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	value6 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	property_id7 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	value7 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	property_id8 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	value8 = {
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
	self.__entity  = "g_role_effectentity"
	return self
end

return cls