local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("u_ara_batmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_ara_bat"
	self.__head    = {
	id = {
		pk = true,
		fk = false,
		cn = "id",
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
	csv_id = {
		pk = false,
		fk = false,
		cn = "csv_id",
		uq = false,
		t = "number",
	},
	date = {
		pk = false,
		fk = false,
		cn = "date",
		uq = false,
		t = "number",
	},
	ser = {
		pk = false,
		fk = false,
		cn = "ser",
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
	is_over = {
		pk = false,
		fk = false,
		cn = "is_over",
		uq = false,
		t = "number",
	},
	res = {
		pk = false,
		fk = false,
		cn = "res",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head[id]
	self.__head_ord[2] = self.__head[user_id]
	self.__head_ord[3] = self.__head[csv_id]
	self.__head_ord[4] = self.__head[date]
	self.__head_ord[5] = self.__head[ser]
	self.__head_ord[6] = self.__head[start_time]
	self.__head_ord[7] = self.__head[is_over]
	self.__head_ord[8] = self.__head[res]

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_ara_batentity"
	return self
end

return cls