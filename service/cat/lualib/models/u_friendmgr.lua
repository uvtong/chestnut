local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("u_friendmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_friend"
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
		fk = false,
		cn = "uid",
		uq = false,
		t = "number",
	},
	friendid = {
		pk = false,
		fk = false,
		cn = "friendid",
		uq = false,
		t = "number",
	},
	isdel = {
		pk = false,
		fk = false,
		cn = "isdel",
		uq = false,
		t = "number",
	},
	recvtime = {
		pk = false,
		fk = false,
		cn = "recvtime",
		uq = false,
		t = "number",
	},
	heartamount = {
		pk = false,
		fk = false,
		cn = "heartamount",
		uq = false,
		t = "number",
	},
	sendtime = {
		pk = false,
		fk = false,
		cn = "sendtime",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["uid"]
	self.__head_ord[3] = self.__head["friendid"]
	self.__head_ord[4] = self.__head["isdel"]
	self.__head_ord[5] = self.__head["recvtime"]
	self.__head_ord[6] = self.__head["heartamount"]
	self.__head_ord[7] = self.__head["sendtime"]

	self.__pk      = "id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_friendentity"
	return self
end

return cls