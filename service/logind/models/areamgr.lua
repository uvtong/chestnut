local skynet = require "skynet"
local modelmgr = require "dbset"
local assert = assert
local type   = type

local cls = class("areamgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "area"
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
	server_id = {
		pk = false,
		fk = false,
		cn = "server_id",
		uq = false,
		t = "number",
	},
	server = {
		pk = false,
		fk = false,
		cn = "server",
		uq = false,
		t = "string",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["uid"]
	self.__head_ord[3] = self.__head["server_id"]
	self.__head_ord[4] = self.__head["server"]

	self.__pk      = "id"
	self.__fk      = ""
	self.__rdb     = ".logind_db"
	self.__wdb     = ".logind_db"
	self.__stm     = false
	self.__entity  = "areaentity"
	return self
end

return cls
