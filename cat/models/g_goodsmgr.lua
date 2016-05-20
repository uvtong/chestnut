local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("g_goodsmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_goods"
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
	currency_type = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	currency_num = {
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
	inventory_init = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	cd = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	icon_id = {
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
	self.__entity  = "g_goodsentity"
	return self
end

return cls