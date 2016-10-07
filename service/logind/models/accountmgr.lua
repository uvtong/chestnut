local skynet = require "skynet"
local modelmgr = require "dbset"
local assert = assert
local type   = type

local cls = class("accountmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "account"
	self.__head    = {
	id = {
		pk = true,
		fk = false,
		cn = "id",
		uq = false,
		t = "number",
	},
	user = {
		pk = false,
		fk = false,
		cn = "user",
		uq = false,
		t = "string",
	},
	password = {
		pk = false,
		fk = false,
		cn = "password",
		uq = false,
		t = "string",
	},
	signuptime = {
		pk = false,
		fk = false,
		cn = "signuptime",
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
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["user"]
	self.__head_ord[3] = self.__head["password"]
	self.__head_ord[4] = self.__head["signuptime"]
	self.__head_ord[5] = self.__head["csv_id"]

	self.__pk      = "id"
	self.__fk      = ""
	self.__rdb     = ".logind_db"
	self.__wdb     = ".logind_db"
	self.__stm     = false
	self.__entity  = "accountentity"
	return self
end

return cls
