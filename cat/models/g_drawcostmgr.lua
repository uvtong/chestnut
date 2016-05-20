local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("g_drawcostmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_drawcost"
	self.__head    = {
	csv_id = {
		pk = true,
		fk = false,
		uq = false,
		t = "number",
	},
	cointype = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	price = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	cdtime = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
}

	self.__pk      = "csv_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_drawcostentity"
	return self
end

return cls