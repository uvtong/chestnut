local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("g_checkpointmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_checkpoint"
	self.__head    = {
	csv_id = {
		pk = true,
		fk = false,
		uq = false,
		t = "number",
	},
	chapter = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	combat = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	level = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	name = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
	checkpoint = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	type = {
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
	gain_gold = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	gain_exp = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	drop = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	reward = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
	monster_csv_id1 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	monster_csv_id2 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	monster_csv_id3 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	drop_cd = {
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
	self.__entity  = "g_checkpointentity"
	return self
end

return cls