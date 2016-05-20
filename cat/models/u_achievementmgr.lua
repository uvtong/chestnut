local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
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
		uq = false,
		t = "number",
	},
	user_id = {
		pk = false,
		fk = true,
		uq = false,
		t = "number",
	},
	csv_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	finished = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	type = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	c_num = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	unlock_next_csv_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	is_unlock = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	is_valid = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
}

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_achievemententity"
	return self
end

return cls