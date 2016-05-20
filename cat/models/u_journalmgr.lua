local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("u_journalmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_journal"
	self.__head    = {
	id = {
		pk = true,
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
	date = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	goods_refresh_count = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	goods_refresh_reset_count = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	ara_rfh_tms = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	ara_bat_ser = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
}

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_journalentity"
	return self
end

return cls