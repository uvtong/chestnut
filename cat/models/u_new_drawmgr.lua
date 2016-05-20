local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("u_new_drawmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_new_draw"
	self.__head    = {
	id = {
		pk = true,
		fk = false,
		uq = false,
		t = "number",
	},
	uid = {
		pk = false,
		fk = true,
		uq = false,
		t = "number",
	},
	drawtype = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	srecvtime = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	propid = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	amount = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	iffree = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
}

	self.__pk      = "id"
	self.__fk      = "uid"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_new_drawentity"
	return self
end

return cls