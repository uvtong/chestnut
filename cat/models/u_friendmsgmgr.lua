local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("u_friendmsgmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_friendmsg"
	self.__head    = {
	id = {
		pk = true,
		fk = false,
		uq = false,
		t = "number",
	},
	fromid = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	toid = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	type = {
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
	propid = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	isread = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	csendtime = {
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
	signtime = {
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
	self.__entity  = "u_friendmsgentity"
	return self
end

return cls