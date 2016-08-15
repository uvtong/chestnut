local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("g_lilian_levelmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_lilian_level"
	self.__head    = {
	csv_id = {
		pk = true,
		fk = false,
		cn = "csv_id",
		uq = false,
		t = "number",
	},
	phy_power = {
		pk = false,
		fk = false,
		cn = "phy_power",
		uq = false,
		t = "number",
	},
	experience = {
		pk = false,
		fk = false,
		cn = "experience",
		uq = false,
		t = "number",
	},
	queue = {
		pk = false,
		fk = false,
		cn = "queue",
		uq = false,
		t = "number",
	},
	dec_lilian_time = {
		pk = false,
		fk = false,
		cn = "dec_lilian_time",
		uq = false,
		t = "number",
	},
	dec_weikun_time = {
		pk = false,
		fk = false,
		cn = "dec_weikun_time",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["csv_id"]
	self.__head_ord[2] = self.__head["phy_power"]
	self.__head_ord[3] = self.__head["experience"]
	self.__head_ord[4] = self.__head["queue"]
	self.__head_ord[5] = self.__head["dec_lilian_time"]
	self.__head_ord[6] = self.__head["dec_weikun_time"]

	self.__pk      = "csv_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_lilian_levelentity"
	return self
end

return cls