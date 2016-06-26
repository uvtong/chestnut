local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("g_lilian_eventmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_lilian_event"
	self.__head    = {
	csv_id = {
		pk = true,
		fk = false,
		cn = "csv_id",
		uq = false,
		t = "number",
	},
	cd_time = {
		pk = false,
		fk = false,
		cn = "cd_time",
		uq = false,
		t = "number",
	},
	description = {
		pk = false,
		fk = false,
		cn = "description",
		uq = false,
		t = "string",
	},
	reward = {
		pk = false,
		fk = false,
		cn = "reward",
		uq = false,
		t = "string",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["csv_id"]
	self.__head_ord[2] = self.__head["cd_time"]
	self.__head_ord[3] = self.__head["description"]
	self.__head_ord[4] = self.__head["reward"]

	self.__pk      = "csv_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_lilian_evententity"
	return self
end

return cls