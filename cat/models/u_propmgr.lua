local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("u_propmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_prop"
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
	num = {
		pk = false,
		fk = false,
		cn = "num",
		uq = false,
		t = "number",
	},
	sub_type = {
		pk = false,
		fk = false,
		cn = "sub_type",
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
	pram1 = {
		pk = false,
		fk = false,
		cn = "pram1",
		uq = false,
		t = "string",
	},
	pram2 = {
		pk = false,
		fk = false,
		cn = "pram2",
		uq = false,
		t = "string",
	},
	name = {
		pk = false,
		fk = false,
		cn = "name",
		uq = false,
		t = "string",
	},
	use_type = {
		pk = false,
		fk = false,
		cn = "use_type",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["user_id"]
	self.__head_ord[3] = self.__head["csv_id"]
	self.__head_ord[4] = self.__head["num"]
	self.__head_ord[5] = self.__head["sub_type"]
	self.__head_ord[6] = self.__head["level"]
	self.__head_ord[7] = self.__head["pram1"]
	self.__head_ord[8] = self.__head["pram2"]
	self.__head_ord[9] = self.__head["name"]
	self.__head_ord[10] = self.__head["use_type"]

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_propentity"
	return self
end

return cls