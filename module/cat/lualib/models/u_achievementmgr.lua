local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("u_achievementmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_achievement"
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
	finished = {
		pk = false,
		fk = false,
		cn = "finished",
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
	c_num = {
		pk = false,
		fk = false,
		cn = "c_num",
		uq = false,
		t = "number",
	},
	unlock_next_csv_id = {
		pk = false,
		fk = false,
		cn = "unlock_next_csv_id",
		uq = false,
		t = "number",
	},
	is_unlock = {
		pk = false,
		fk = false,
		cn = "is_unlock",
		uq = false,
		t = "number",
	},
	is_valid = {
		pk = false,
		fk = false,
		cn = "is_valid",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["user_id"]
	self.__head_ord[3] = self.__head["csv_id"]
	self.__head_ord[4] = self.__head["finished"]
	self.__head_ord[5] = self.__head["type"]
	self.__head_ord[6] = self.__head["c_num"]
	self.__head_ord[7] = self.__head["unlock_next_csv_id"]
	self.__head_ord[8] = self.__head["is_unlock"]
	self.__head_ord[9] = self.__head["is_valid"]

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_achievemententity"
	return self
end

return cls