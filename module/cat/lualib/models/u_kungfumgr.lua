local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("u_kungfumgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_kungfu"
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
	csv_id = {
		pk = false,
		fk = false,
		cn = "csv_id",
		uq = false,
		t = "number",
	},
	level = {
		pk = false,
		fk = false,
		cn = "level",
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
	sp_id = {
		pk = false,
		fk = false,
		cn = "sp_id",
		uq = false,
		t = "number",
	},
	g_csv_id = {
		pk = false,
		fk = false,
		cn = "g_csv_id",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["user_id"]
	self.__head_ord[3] = self.__head["csv_id"]
	self.__head_ord[4] = self.__head["level"]
	self.__head_ord[5] = self.__head["type"]
	self.__head_ord[6] = self.__head["sp_id"]
	self.__head_ord[7] = self.__head["g_csv_id"]

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_kungfuentity"
	return self
end

return cls