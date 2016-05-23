local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("u_lilian_submgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_lilian_sub"
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
		fk = true,
		cn = "csv_id",
		uq = false,
		t = "number",
	},
	first_lilian_time = {
		pk = false,
		fk = false,
		cn = "first_lilian_time",
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
	update_time = {
		pk = false,
		fk = false,
		cn = "update_time",
		uq = false,
		t = "number",
	},
	used_queue_num = {
		pk = false,
		fk = false,
		cn = "used_queue_num",
		uq = false,
		t = "number",
	},
	end_lilian_time = {
		pk = false,
		fk = false,
		cn = "end_lilian_time",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["csv_id"]
	self.__head_ord[3] = self.__head["first_lilian_time"]
	self.__head_ord[4] = self.__head["start_time"]
	self.__head_ord[5] = self.__head["update_time"]
	self.__head_ord[6] = self.__head["used_queue_num"]
	self.__head_ord[7] = self.__head["end_lilian_time"]

	self.__pk      = "id"
	self.__fk      = "csv_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_lilian_subentity"
	return self
end

return cls