local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("g_checkpoint_chaptermgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_checkpoint_chapter"
	self.__head    = {
	csv_id = {
		pk = true,
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
	name = {
		pk = false,
		fk = false,
		cn = "name",
		uq = false,
		t = "string",
	},
	type0_max = {
		pk = false,
		fk = false,
		cn = "type0_max",
		uq = false,
		t = "number",
	},
	type1_max = {
		pk = false,
		fk = false,
		cn = "type1_max",
		uq = false,
		t = "number",
	},
	type2_max = {
		pk = false,
		fk = false,
		cn = "type2_max",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["csv_id"]
	self.__head_ord[2] = self.__head["level"]
	self.__head_ord[3] = self.__head["name"]
	self.__head_ord[4] = self.__head["type0_max"]
	self.__head_ord[5] = self.__head["type1_max"]
	self.__head_ord[6] = self.__head["type2_max"]

	self.__pk      = "csv_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_checkpoint_chapterentity"
	return self
end

return cls