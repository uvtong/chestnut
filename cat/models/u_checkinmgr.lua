local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("u_checkinmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_checkin"
	self.__head    = {
	id = {
		pk = true,
		fk = false,
		cn = "id",
		uq = false,
		t = "number",
	},
	if_latest = {
		pk = false,
		fk = false,
		cn = "if_latest",
		uq = false,
		t = "number",
	},
	user_id = {
		pk = false,
		fk = true,
		cn = "user_id",
		uq = false,
		t = "number",
	},
	u_checkin_time = {
		pk = false,
		fk = false,
		cn = "u_checkin_time",
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
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["if_latest"]
	self.__head_ord[3] = self.__head["user_id"]
	self.__head_ord[4] = self.__head["u_checkin_time"]
	self.__head_ord[5] = self.__head["update_time"]

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_checkinentity"
	return self
end

return cls