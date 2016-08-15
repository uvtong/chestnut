local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("test_student3mgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "test_student3"
	self.__head    = {
	id = {
		pk = true,
		fk = false,
		cn = "id",
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
	age = {
		pk = false,
		fk = false,
		cn = "age",
		uq = false,
		t = "number",
	},
	remark = {
		pk = false,
		fk = false,
		cn = "remark",
		uq = false,
		t = "string",
	},
	tfloat = {
		pk = false,
		fk = false,
		cn = "tfloat",
		uq = false,
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head[id]
	self.__head_ord[2] = self.__head[name]
	self.__head_ord[3] = self.__head[age]
	self.__head_ord[4] = self.__head[remark]
	self.__head_ord[5] = self.__head[tfloat]

	self.__pk      = "id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "test_student3entity"
	return self
end

return cls