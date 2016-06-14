local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("u_new_friendmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_new_friend"
	self.__head    = {
	id = {
		pk = true,
		fk = false,
		cn = "id",
		uq = false,
		t = "number",
	},
	self_csv_id = {
		pk = false,
		fk = true,
		cn = "self_csv_id",
		uq = false,
		t = "number",
	},
	friend_csv_id = {
		pk = false,
		fk = false,
		cn = "friend_csv_id",
		uq = false,
		t = "number",
	},
	isdelete = {
		pk = false,
		fk = false,
		cn = "isdelete",
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
	update_time = {
		pk = false,
		fk = false,
		cn = "update_time",
		uq = false,
		t = "number",
	},
	ifrecved = {
		pk = false,
		fk = false,
		cn = "ifrecved",
		uq = false,
		t = "number",
	},
	ifsent = {
		pk = false,
		fk = false,
		cn = "ifsent",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["self_csv_id"]
	self.__head_ord[3] = self.__head["friend_csv_id"]
	self.__head_ord[4] = self.__head["isdelete"]
	self.__head_ord[5] = self.__head["recvtime"]
	self.__head_ord[6] = self.__head["heartamount"]
	self.__head_ord[7] = self.__head["update_time"]
	self.__head_ord[8] = self.__head["ifrecved"]
	self.__head_ord[9] = self.__head["ifsent"]

	self.__pk      = "id"
	self.__fk      = "self_csv_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_new_friendentity"
	return self
end

return cls