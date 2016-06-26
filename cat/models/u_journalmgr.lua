local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
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
	date = {
		pk = false,
		fk = false,
		cn = "date",
		uq = false,
		t = "number",
	},
	goods_refresh_count = {
		pk = false,
		fk = false,
		cn = "goods_refresh_count",
		uq = false,
		t = "number",
	},
	goods_refresh_reset_count = {
		pk = false,
		fk = false,
		cn = "goods_refresh_reset_count",
		uq = false,
		t = "number",
	},
	ara_rfh_tms = {
		pk = false,
		fk = false,
		cn = "ara_rfh_tms",
		uq = false,
		t = "number",
	},
	ara_bat_ser = {
		pk = false,
		fk = false,
		cn = "ara_bat_ser",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["user_id"]
	self.__head_ord[3] = self.__head["date"]
	self.__head_ord[4] = self.__head["goods_refresh_count"]
	self.__head_ord[5] = self.__head["goods_refresh_reset_count"]
	self.__head_ord[6] = self.__head["ara_rfh_tms"]
	self.__head_ord[7] = self.__head["ara_bat_ser"]

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_journalentity"
	return self
end

return cls