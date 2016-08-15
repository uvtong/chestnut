local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("g_configmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_config"
	self.__head    = {
	csv_id = {
		pk = true,
		fk = false,
		cn = "csv_id",
		uq = false,
		t = "number",
	},
	user_level_max = {
		pk = false,
		fk = false,
		cn = "user_level_max",
		uq = false,
		t = "number",
	},
	user_vip_max = {
		pk = false,
		fk = false,
		cn = "user_vip_max",
		uq = false,
		t = "number",
	},
	xilian_begain_level = {
		pk = false,
		fk = false,
		cn = "xilian_begain_level",
		uq = false,
		t = "number",
	},
	cp_chapter_max = {
		pk = false,
		fk = false,
		cn = "cp_chapter_max",
		uq = false,
		t = "number",
	},
	purch_phy_power = {
		pk = false,
		fk = false,
		cn = "purch_phy_power",
		uq = false,
		t = "number",
	},
	diamond_per_sec = {
		pk = false,
		fk = false,
		cn = "diamond_per_sec",
		uq = false,
		t = "number",
	},
	ara_clg_tms_rst_tp = {
		pk = false,
		fk = false,
		cn = "ara_clg_tms_rst_tp",
		uq = false,
		t = "number",
	},
	worship_reward_id = {
		pk = false,
		fk = false,
		cn = "worship_reward_id",
		uq = false,
		t = "number",
	},
	worship_reward_num = {
		pk = false,
		fk = false,
		cn = "worship_reward_num",
		uq = false,
		t = "number",
	},
	ara_clg_tms_max = {
		pk = false,
		fk = false,
		cn = "ara_clg_tms_max",
		uq = false,
		t = "number",
	},
	ara_clg_tms_rst = {
		pk = false,
		fk = false,
		cn = "ara_clg_tms_rst",
		uq = false,
		t = "number",
	},
	ara_integral_rst = {
		pk = false,
		fk = false,
		cn = "ara_integral_rst",
		uq = false,
		t = "number",
	},
	ara_clg_tms_pur_tms_rst = {
		pk = false,
		fk = false,
		cn = "ara_clg_tms_pur_tms_rst",
		uq = false,
		t = "number",
	},
	ara_rfh_dt = {
		pk = false,
		fk = false,
		cn = "ara_rfh_dt",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["csv_id"]
	self.__head_ord[2] = self.__head["user_level_max"]
	self.__head_ord[3] = self.__head["user_vip_max"]
	self.__head_ord[4] = self.__head["xilian_begain_level"]
	self.__head_ord[5] = self.__head["cp_chapter_max"]
	self.__head_ord[6] = self.__head["purch_phy_power"]
	self.__head_ord[7] = self.__head["diamond_per_sec"]
	self.__head_ord[8] = self.__head["ara_clg_tms_rst_tp"]
	self.__head_ord[9] = self.__head["worship_reward_id"]
	self.__head_ord[10] = self.__head["worship_reward_num"]
	self.__head_ord[11] = self.__head["ara_clg_tms_max"]
	self.__head_ord[12] = self.__head["ara_clg_tms_rst"]
	self.__head_ord[13] = self.__head["ara_integral_rst"]
	self.__head_ord[14] = self.__head["ara_clg_tms_pur_tms_rst"]
	self.__head_ord[15] = self.__head["ara_rfh_dt"]

	self.__pk      = "csv_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_configentity"
	return self
end

return cls