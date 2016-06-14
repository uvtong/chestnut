local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local assert = assert
local type   = type

local cls = class("logintimesmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "logintimes"
	self.__head    = {
	uid = {
		pk = true,
		fk = false,
		cn = "uid",
		uq = false,
		t = "number",
	},
	times = {
		pk = false,
		fk = false,
		cn = "times",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["uid"]
	self.__head_ord[2] = self.__head["times"]

	self.__pk      = "uid"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "logintimesentity"
	return self
end

return cls