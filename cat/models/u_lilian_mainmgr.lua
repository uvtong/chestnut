local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("u_lilian_mainmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_lilian_main"
	self.__head    = {
	id = {
		pk = true,
		fk = false,
		cn = "id",
		uq = false,
		t = "number",
	},
	csv_id = {
		pk = false,
		fk = false,
		cn = "csv_id",
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
	quanguan_id = {
		pk = false,
		fk = false,
		cn = "quanguan_id",
		uq = false,
		t = "number",
	},
	start_time = {
		pk = false,
		fk = false,
		cn = "start_time",
		uq = false,
		t = "number",
	},
	end_time = {
		pk = false,
		fk = false,
		cn = "end_time",
		uq = false,
		t = "number",
	},
	if_trigger_event = {
		pk = false,
		fk = false,
		cn = "if_trigger_event",
		uq = false,
		t = "number",
	},
	iffinished = {
		pk = false,
		fk = false,
		cn = "iffinished",
		uq = false,
		t = "number",
	},
	invitation_id = {
		pk = false,
		fk = false,
		cn = "invitation_id",
		uq = false,
		t = "number",
	},
	iflevel_up = {
		pk = false,
		fk = false,
		cn = "iflevel_up",
		uq = false,
		t = "number",
	},
	event_start_time = {
		pk = false,
		fk = false,
		cn = "event_start_time",
		uq = false,
		t = "number",
	},
	event_end_time = {
		pk = false,
		fk = false,
		cn = "event_end_time",
		uq = false,
		t = "number",
	},
	if_lilian_finished = {
		pk = false,
		fk = false,
		cn = "if_lilian_finished",
		uq = false,
		t = "number",
	},
	eventid = {
		pk = false,
		fk = false,
		cn = "eventid",
		uq = false,
		t = "number",
	},
	if_canceled = {
		pk = false,
		fk = false,
		cn = "if_canceled",
		uq = false,
		t = "number",
	},
	if_event_canceled = {
		pk = false,
		fk = false,
		cn = "if_event_canceled",
		uq = false,
		t = "number",
	},
	if_lilian_reward = {
		pk = false,
		fk = false,
		cn = "if_lilian_reward",
		uq = false,
		t = "number",
	},
	if_event_reward = {
		pk = false,
		fk = false,
		cn = "if_event_reward",
		uq = false,
		t = "number",
	},
	event_reward = {
		pk = false,
		fk = false,
		cn = "event_reward",
		uq = false,
		t = "string",
	},
	lilian_reward = {
		pk = false,
		fk = false,
		cn = "lilian_reward",
		uq = false,
		t = "string",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["csv_id"]
	self.__head_ord[3] = self.__head["user_id"]
	self.__head_ord[4] = self.__head["quanguan_id"]
	self.__head_ord[5] = self.__head["start_time"]
	self.__head_ord[6] = self.__head["end_time"]
	self.__head_ord[7] = self.__head["if_trigger_event"]
	self.__head_ord[8] = self.__head["iffinished"]
	self.__head_ord[9] = self.__head["invitation_id"]
	self.__head_ord[10] = self.__head["iflevel_up"]
	self.__head_ord[11] = self.__head["event_start_time"]
	self.__head_ord[12] = self.__head["event_end_time"]
	self.__head_ord[13] = self.__head["if_lilian_finished"]
	self.__head_ord[14] = self.__head["eventid"]
	self.__head_ord[15] = self.__head["if_canceled"]
	self.__head_ord[16] = self.__head["if_event_canceled"]
	self.__head_ord[17] = self.__head["if_lilian_reward"]
	self.__head_ord[18] = self.__head["if_event_reward"]
	self.__head_ord[19] = self.__head["event_reward"]
	self.__head_ord[20] = self.__head["lilian_reward"]

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_lilian_mainentity"
	return self
end

return cls