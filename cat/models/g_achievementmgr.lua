local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("g_achievementmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_achievement"
	self.__head    = {
	csv_id = {
		pk = true,
		fk = false,
		cn = "csv_id",
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
	name = {
		pk = false,
		fk = false,
		cn = "name",
		uq = false,
		t = "string",
	},
	c_num = {
		pk = false,
		fk = false,
		cn = "c_num",
		uq = false,
		t = "number",
	},
	describe = {
		pk = false,
		fk = false,
		cn = "describe",
		uq = false,
		t = "string",
	},
	icon_id = {
		pk = false,
		fk = false,
		cn = "icon_id",
		uq = false,
		t = "number",
	},
	reward = {
		pk = false,
		fk = false,
		cn = "reward",
		uq = false,
		t = "string",
	},
	star = {
		pk = false,
		fk = false,
		cn = "star",
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
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["csv_id"]
	self.__head_ord[2] = self.__head["type"]
	self.__head_ord[3] = self.__head["name"]
	self.__head_ord[4] = self.__head["c_num"]
	self.__head_ord[5] = self.__head["describe"]
	self.__head_ord[6] = self.__head["icon_id"]
	self.__head_ord[7] = self.__head["reward"]
	self.__head_ord[8] = self.__head["star"]
	self.__head_ord[9] = self.__head["unlock_next_csv_id"]

	self.__pk      = "csv_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_achievemententity"
	return self
end

return cls