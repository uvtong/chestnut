local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("u_checkpointmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_checkpoint"
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
	chapter = {
		pk = false,
		fk = false,
		cn = "chapter",
		uq = false,
		t = "number",
	},
	chapter_type0 = {
		pk = false,
		fk = false,
		cn = "chapter_type0",
		uq = false,
		t = "number",
	},
	chapter_type1 = {
		pk = false,
		fk = false,
		cn = "chapter_type1",
		uq = false,
		t = "number",
	},
	chapter_type2 = {
		pk = false,
		fk = false,
		cn = "chapter_type2",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["user_id"]
	self.__head_ord[3] = self.__head["chapter"]
	self.__head_ord[4] = self.__head["chapter_type0"]
	self.__head_ord[5] = self.__head["chapter_type1"]
	self.__head_ord[6] = self.__head["chapter_type2"]

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_checkpointentity"
	return self
end

return cls