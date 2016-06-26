local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
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
		cn = "csv_id",
		uq = false,
		t = "number",
	},
	chapter = {
		pk = false,
		fk = false,
		cn = "chapter",
		uq = false,
		t = "number",
	},
	combat = {
		pk = false,
		fk = false,
		cn = "combat",
		uq = false,
		t = "number",
	},
	level = {
		pk = false,
		fk = false,
		cn = "level",
		uq = false,
		t = "number",
	},
	name = {
		pk = false,
		fk = false,
		cn = "name",
		uq = false,
		t = "string",
	},
	checkpoint = {
		pk = false,
		fk = false,
		cn = "checkpoint",
		uq = false,
		t = "number",
	},
	type = {
		pk = false,
		fk = false,
		cn = "type",
		uq = false,
		t = "number",
	},
	cd = {
		pk = false,
		fk = false,
		cn = "cd",
		uq = false,
		t = "number",
	},
	gain_gold = {
		pk = false,
		fk = false,
		cn = "gain_gold",
		uq = false,
		t = "number",
	},
	gain_exp = {
		pk = false,
		fk = false,
		cn = "gain_exp",
		uq = false,
		t = "number",
	},
	drop = {
		pk = false,
		fk = false,
		cn = "drop",
		uq = false,
		t = "number",
	},
	reward = {
		pk = false,
		fk = false,
		cn = "reward",
		uq = false,
		t = "string",
	},
	monster_csv_id1 = {
		pk = false,
		fk = false,
		cn = "monster_csv_id1",
		uq = false,
		t = "number",
	},
	monster_csv_id2 = {
		pk = false,
		fk = false,
		cn = "monster_csv_id2",
		uq = false,
		t = "number",
	},
	monster_csv_id3 = {
		pk = false,
		fk = false,
		cn = "monster_csv_id3",
		uq = false,
		t = "number",
	},
	drop_cd = {
		pk = false,
		fk = false,
		cn = "drop_cd",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["csv_id"]
	self.__head_ord[2] = self.__head["chapter"]
	self.__head_ord[3] = self.__head["combat"]
	self.__head_ord[4] = self.__head["level"]
	self.__head_ord[5] = self.__head["name"]
	self.__head_ord[6] = self.__head["checkpoint"]
	self.__head_ord[7] = self.__head["type"]
	self.__head_ord[8] = self.__head["cd"]
	self.__head_ord[9] = self.__head["gain_gold"]
	self.__head_ord[10] = self.__head["gain_exp"]
	self.__head_ord[11] = self.__head["drop"]
	self.__head_ord[12] = self.__head["reward"]
	self.__head_ord[13] = self.__head["monster_csv_id1"]
	self.__head_ord[14] = self.__head["monster_csv_id2"]
	self.__head_ord[15] = self.__head["monster_csv_id3"]
	self.__head_ord[16] = self.__head["drop_cd"]

	self.__pk      = "csv_id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_checkpointentity"
	return self
end

return cls