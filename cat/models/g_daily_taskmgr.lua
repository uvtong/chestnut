local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("g_daily_taskmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_daily_task"
	self.__head    = {
	id = {
		pk = true,
		fk = false,
		uq = false,
		t = "number",
	},
	update_time = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
	type = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	task_name = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
	cost_amount = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	iconid = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	basic_reward = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
	levelup_reward = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
	level_up = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	cost_id = {
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
	self.__entity  = "g_daily_taskentity"
	return self
end

return cls