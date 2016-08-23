local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("u_ara_journalmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_ara_journal"
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
	ara_clg_tms = {
		pk = false,
		fk = false,
		cn = "ara_clg_tms",
		uq = false,
		t = "number",
	},
	ara_clg_tms_pur_tms = {
		pk = false,
		fk = false,
		cn = "ara_clg_tms_pur_tms",
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
	self.__head_ord[3] = self.__head["csv_id"]
	self.__head_ord[4] = self.__head["date"]
	self.__head_ord[5] = self.__head["ara_clg_tms"]
	self.__head_ord[6] = self.__head["ara_clg_tms_pur_tms"]
	self.__head_ord[7] = self.__head["ara_rfh_tms"]
	self.__head_ord[8] = self.__head["ara_bat_ser"]

	self.__pk      = "id"
	self.__fk      = "user_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_ara_journalentity"
	return self
end

return cls