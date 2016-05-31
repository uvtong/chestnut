local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("u_exercisemgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_exercise"
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
	exercise_time = {
		pk = false,
		fk = false,
		cn = "exercise_time",
		uq = false,
		t = "number",
	},
	exercise_type = {
		pk = false,
		fk = false,
		cn = "exercise_type",
		uq = false,
		t = "number",
	},
	time_length = {
		pk = false,
		fk = false,
		cn = "time_length",
		uq = false,
		t = "number",
	},
	if_latest = {
		pk = false,
		fk = false,
		cn = "if_latest",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["user_id"]
	self.__head_ord[3] = self.__head["exercise_time"]
	self.__head_ord[4] = self.__head["exercise_type"]
	self.__head_ord[5] = self.__head["time_length"]
	self.__head_ord[6] = self.__head["if_latest"]

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_exerciseentity"
	return self
end

return cls