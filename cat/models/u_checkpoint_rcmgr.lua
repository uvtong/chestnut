local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("u_checkpoint_rcmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_checkpoint_rc"
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
	passed = {
		pk = false,
		fk = false,
		cn = "passed",
		uq = false,
		t = "number",
	},
	cd_walk = {
		pk = false,
		fk = false,
		cn = "cd_walk",
		uq = false,
		t = "number",
	},
	cd_starttime = {
		pk = false,
		fk = false,
		cn = "cd_starttime",
		uq = false,
		t = "number",
	},
	cd_finished = {
		pk = false,
		fk = false,
		cn = "cd_finished",
		uq = false,
		t = "number",
	},
	hanging_starttime = {
		pk = false,
		fk = false,
		cn = "hanging_starttime",
		uq = false,
		t = "number",
	},
	hanging_walk = {
		pk = false,
		fk = false,
		cn = "hanging_walk",
		uq = false,
		t = "number",
	},
	hanging_drop_starttime = {
		pk = false,
		fk = false,
		cn = "hanging_drop_starttime",
		uq = false,
		t = "number",
	},
	hanging_drop_walk = {
		pk = false,
		fk = false,
		cn = "hanging_drop_walk",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["user_id"]
	self.__head_ord[3] = self.__head["csv_id"]
	self.__head_ord[4] = self.__head["passed"]
	self.__head_ord[5] = self.__head["cd_walk"]
	self.__head_ord[6] = self.__head["cd_starttime"]
	self.__head_ord[7] = self.__head["cd_finished"]
	self.__head_ord[8] = self.__head["hanging_starttime"]
	self.__head_ord[9] = self.__head["hanging_walk"]
	self.__head_ord[10] = self.__head["hanging_drop_starttime"]
	self.__head_ord[11] = self.__head["hanging_drop_walk"]

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_checkpoint_rcentity"
	return self
end

return cls