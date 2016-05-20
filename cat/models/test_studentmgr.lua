local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("test_studentmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "test_student"
	self.__head    = {
	id = {
		pk = true,
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
	age = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	remark = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
	tfloat = {
		pk = false,
		fk = false,
		uq = false,
	},
}

	self.__pk      = "id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "test_studententity"
	return self
end

return cls