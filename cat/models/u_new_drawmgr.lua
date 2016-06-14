local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
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
		cn = "id",
		uq = false,
		t = "number",
	},
	uid = {
		pk = false,
		fk = true,
		cn = "uid",
		uq = false,
		t = "number",
	},
	drawtype = {
		pk = false,
		fk = false,
		cn = "drawtype",
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
	propid = {
		pk = false,
		fk = false,
		cn = "propid",
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
	iffree = {
		pk = false,
		fk = false,
		cn = "iffree",
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
	is_latest = {
		pk = false,
		fk = false,
		cn = "is_latest",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["uid"]
	self.__head_ord[3] = self.__head["drawtype"]
	self.__head_ord[4] = self.__head["srecvtime"]
	self.__head_ord[5] = self.__head["propid"]
	self.__head_ord[6] = self.__head["amount"]
	self.__head_ord[7] = self.__head["iffree"]
	self.__head_ord[8] = self.__head["updatetime"]
	self.__head_ord[9] = self.__head["is_latest"]

	self.__pk      = "id"
	self.__fk      = "uid"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_new_drawentity"
	return self
end

return cls