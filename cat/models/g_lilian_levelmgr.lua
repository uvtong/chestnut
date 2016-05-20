local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("g_lilian_levelmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_lilian_level"
	self.__head    = {
	id = {
		pk = true,
		fk = false,
		uq = false,
		t = "number",
	},
	csv_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	phy_power = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	experience = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	queue = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	dec_lilian_time = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	dec_weikun_time = {
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
	self.__entity  = "g_lilian_levelentity"
	return self
end

return cls