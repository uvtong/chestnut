local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("g_checkinmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_checkin"
	self.__head    = {
	csv_id = {
		pk = true,
		fk = false,
		uq = false,
		t = "number",
	},
	month = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	count = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	g_prop_csv_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	g_prop_num = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	vip = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	vip_g_prop_csv_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	vip_g_prop_num = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
}

	self.__pk      = "csv_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_checkinentity"
	return self
end

return cls