local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("g_monstermgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_monster"
	self.__head    = {
	id = {
		pk = true,
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
	combat = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	defense = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	critical_hit = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	blessing = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	quanfaid = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
}

	self.__pk      = "id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_monsterentity"
	return self
end

return cls