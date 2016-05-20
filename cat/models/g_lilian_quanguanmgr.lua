local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("g_lilian_quanguanmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_lilian_quanguan"
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
	belong_zone = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	open_level = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	time = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	reward = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
	day_finish_time = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	need_phy_power = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	reward_exp = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	trigger_event_prop = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	trigger_event = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
}

	self.__pk      = "id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_lilian_quanguanentity"
	return self
end

return cls