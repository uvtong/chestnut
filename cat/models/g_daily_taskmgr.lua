local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
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
		pk = false,
		fk = false,
		cn = "id",
		uq = false,
		t = "number",
	},
	update_time = {
		pk = false,
		fk = false,
		cn = "update_time",
		uq = false,
		t = "string",
	},
	type = {
		pk = true,
		fk = false,
		cn = "type",
		uq = false,
		t = "number",
	},
	task_name = {
		pk = false,
		fk = false,
		cn = "task_name",
		uq = false,
		t = "string",
	},
	cost_amount = {
		pk = false,
		fk = false,
		cn = "cost_amount",
		uq = false,
		t = "number",
	},
	iconid = {
		pk = false,
		fk = false,
		cn = "iconid",
		uq = false,
		t = "number",
	},
	basic_reward = {
		pk = false,
		fk = false,
		cn = "basic_reward",
		uq = false,
		t = "string",
	},
	levelup_reward = {
		pk = false,
		fk = false,
		cn = "levelup_reward",
		uq = false,
		t = "string",
	},
	level_up = {
		pk = false,
		fk = false,
		cn = "level_up",
		uq = false,
		t = "number",
	},
	cost_id = {
		pk = false,
		fk = false,
		cn = "cost_id",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["update_time"]
	self.__head_ord[3] = self.__head["type"]
	self.__head_ord[4] = self.__head["task_name"]
	self.__head_ord[5] = self.__head["cost_amount"]
	self.__head_ord[6] = self.__head["iconid"]
	self.__head_ord[7] = self.__head["basic_reward"]
	self.__head_ord[8] = self.__head["levelup_reward"]
	self.__head_ord[9] = self.__head["level_up"]
	self.__head_ord[10] = self.__head["cost_id"]

	self.__pk      = "type"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_daily_taskentity"
	return self
end

return cls