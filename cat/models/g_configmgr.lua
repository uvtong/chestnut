local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
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
		uq = false,
		t = "number",
	},
	user_level_max = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	user_vip_max = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	xilian_begain_level = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	cp_chapter_max = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	purch_phy_power = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	diamond_per_sec = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	ara_clg_tms_rst_tp = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	worship_reward_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	worship_reward_num = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	ara_clg_tms_max = {
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
	self.__entity  = "g_configentity"
	return self
end

return cls