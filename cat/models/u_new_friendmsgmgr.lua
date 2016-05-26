local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("u_new_friendmsgmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_new_friendmsg"
	self.__head    = {
	id = {
		pk = true,
		fk = false,
		cn = "id",
		uq = false,
		t = "number",
	},
	fromid = {
		pk = false,
		fk = false,
		cn = "fromid",
		uq = false,
		t = "number",
	},
	toid = {
		pk = false,
		fk = false,
		cn = "toid",
		uq = false,
		t = "number",
	},
	type = {
		pk = false,
		fk = false,
		cn = "type",
		uq = false,
		t = "number",
	},
	amount = {
		pk = false,
		fk = false,
		cn = "amount",
		uq = false,
		t = "number",
	},
	isread = {
		pk = false,
		fk = false,
		cn = "isread",
		uq = false,
		t = "number",
	},
	srecvtime = {
		pk = false,
		fk = false,
		cn = "srecvtime",
		uq = false,
		t = "number",
	},
	updatetime = {
		pk = false,
		fk = false,
		cn = "updatetime",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["fromid"]
	self.__head_ord[3] = self.__head["toid"]
	self.__head_ord[4] = self.__head["type"]
	self.__head_ord[5] = self.__head["amount"]
	self.__head_ord[6] = self.__head["isread"]
	self.__head_ord[7] = self.__head["srecvtime"]
	self.__head_ord[8] = self.__head["updatetime"]

	self.__pk      = "id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_new_friendmsgentity"
	return self
end

return cls