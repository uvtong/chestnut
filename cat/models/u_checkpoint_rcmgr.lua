local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
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
	passed = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	cd_starttime = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	cd_finished = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	cd_walk = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	hanging_starttime = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	hanging_walk = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	hanging_drop_starttime = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	hanging_drop_walk = {
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
	self.__entity  = "u_checkpoint_rcentity"
	return self
end

return cls