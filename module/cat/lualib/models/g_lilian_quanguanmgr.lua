local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
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
	csv_id = {
		pk = true,
		fk = false,
		cn = "csv_id",
		uq = false,
		t = "number",
	},
	belong_zone = {
		pk = false,
		fk = false,
		cn = "belong_zone",
		uq = false,
		t = "number",
	},
	open_level = {
		pk = false,
		fk = false,
		cn = "open_level",
		uq = false,
		t = "number",
	},
	time = {
		pk = false,
		fk = false,
		cn = "time",
		uq = false,
		t = "number",
	},
	reward = {
		pk = false,
		fk = false,
		cn = "reward",
		uq = false,
		t = "string",
	},
	day_finish_time = {
		pk = false,
		fk = false,
		cn = "day_finish_time",
		uq = false,
		t = "number",
	},
	need_phy_power = {
		pk = false,
		fk = false,
		cn = "need_phy_power",
		uq = false,
		t = "number",
	},
	reward_exp = {
		pk = false,
		fk = false,
		cn = "reward_exp",
		uq = false,
		t = "number",
	},
	trigger_event_prop = {
		pk = false,
		fk = false,
		cn = "trigger_event_prop",
		uq = false,
		t = "number",
	},
	trigger_event = {
		pk = false,
		fk = false,
		cn = "trigger_event",
		uq = false,
		t = "string",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["csv_id"]
	self.__head_ord[2] = self.__head["belong_zone"]
	self.__head_ord[3] = self.__head["open_level"]
	self.__head_ord[4] = self.__head["time"]
	self.__head_ord[5] = self.__head["reward"]
	self.__head_ord[6] = self.__head["day_finish_time"]
	self.__head_ord[7] = self.__head["need_phy_power"]
	self.__head_ord[8] = self.__head["reward_exp"]
	self.__head_ord[9] = self.__head["trigger_event_prop"]
	self.__head_ord[10] = self.__head["trigger_event"]

	self.__pk      = "csv_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_lilian_quanguanentity"
	return self
end

return cls