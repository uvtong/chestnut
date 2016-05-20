local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("g_user_levelmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_user_level"
	self.__head    = {
	id = {
		pk = true,
		fk = false,
		uq = false,
		t = "number",
	},
	level = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	exp = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	combat = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	defense = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	critical_hit = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	skill = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	gold_max = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	exp_max = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
}

	self.__pk      = "id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_user_levelentity"
	return self
end

return cls