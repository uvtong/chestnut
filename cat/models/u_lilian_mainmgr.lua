local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
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
		uq = false,
		t = "number",
	},
	csv_id = {
		pk = false,
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
	quanguan_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	start_time = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	end_time = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	if_trigger_event = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	iffinished = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	invitation_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	iflevel_up = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	event_start_time = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	event_end_time = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	if_lilian_finished = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	eventid = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	if_canceled = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	if_event_canceled = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	if_lilian_reward = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	if_event_reward = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	event_reward = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
	lilian_reward = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
}

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_lilian_mainentity"
	return self
end

return cls