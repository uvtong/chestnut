local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("ara_leaderboardsmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "ara_leaderboards"
	self.__head    = {
	uid = {
		pk = true,
		fk = false,
		cn = "uid",
		uq = false,
		t = "number",
	},
	ranking = {
		pk = false,
		fk = false,
		cn = "ranking",
		uq = false,
		t = "number",
	},
	k = {
		pk = false,
		fk = false,
		cn = "k",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["uid"]
	self.__head_ord[2] = self.__head["ranking"]
	self.__head_ord[3] = self.__head["k"]

	self.__pk      = "uid"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "ara_leaderboardsentity"
	return self
end

return cls