local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("u_ara_worship_rcmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_ara_worship_rc"
	self.__head    = {
	id = {
		pk = true,
		fk = false,
		cn = "id",
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
	ouid = {
		pk = false,
		fk = false,
		cn = "ouid",
		uq = false,
		t = "number",
	},
	date = {
		pk = false,
		fk = false,
		cn = "date",
		uq = false,
		t = "number",
	},
	worship = {
		pk = false,
		fk = false,
		cn = "worship",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["user_id"]
	self.__head_ord[3] = self.__head["ouid"]
	self.__head_ord[4] = self.__head["date"]
	self.__head_ord[5] = self.__head["worship"]

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_ara_worship_rcentity"
	return self
end

return cls