local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
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
	buffer_id = {
		pk = true,
		fk = false,
		cn = "buffer_id",
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
	property_id6 = {
		pk = false,
		fk = false,
		cn = "property_id6",
		uq = false,
		t = "number",
	},
	value6 = {
		pk = false,
		fk = false,
		cn = "value6",
		uq = false,
		t = "number",
	},
	property_id7 = {
		pk = false,
		fk = false,
		cn = "property_id7",
		uq = false,
		t = "number",
	},
	value7 = {
		pk = false,
		fk = false,
		cn = "value7",
		uq = false,
		t = "number",
	},
	property_id8 = {
		pk = false,
		fk = false,
		cn = "property_id8",
		uq = false,
		t = "number",
	},
	value8 = {
		pk = false,
		fk = false,
		cn = "value8",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["buffer_id"]
	self.__head_ord[2] = self.__head["property_id1"]
	self.__head_ord[3] = self.__head["value1"]
	self.__head_ord[4] = self.__head["property_id2"]
	self.__head_ord[5] = self.__head["value2"]
	self.__head_ord[6] = self.__head["property_id3"]
	self.__head_ord[7] = self.__head["value3"]
	self.__head_ord[8] = self.__head["property_id4"]
	self.__head_ord[9] = self.__head["value4"]
	self.__head_ord[10] = self.__head["property_id5"]
	self.__head_ord[11] = self.__head["value5"]
	self.__head_ord[12] = self.__head["property_id6"]
	self.__head_ord[13] = self.__head["value6"]
	self.__head_ord[14] = self.__head["property_id7"]
	self.__head_ord[15] = self.__head["value7"]
	self.__head_ord[16] = self.__head["property_id8"]
	self.__head_ord[17] = self.__head["value8"]

	self.__pk      = "buffer_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_role_effectentity"
	return self
end

return cls