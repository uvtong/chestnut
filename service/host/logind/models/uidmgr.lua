local skynet = require "skynet"
local modelmgr = require "dbset"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("uidmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "uid"
	self.__head    = {
	id = {
		pk = true,
		fk = false,
		cn = "id",
		uq = false,
		t = "number",
	},
	entropy = {
		pk = false,
		fk = false,
		cn = "entropy",
		uq = false,
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head[id]
	self.__head_ord[2] = self.__head[entropy]

	self.__pk      = "id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "uidentity"
	return self
end

return cls