local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("u_friendmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_friend"
	self.__head    = {
	id = {
		pk = true,
		fk = false,
		uq = false,
		t = "number",
	},
	uid = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	friendid = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	isdel = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	recvtime = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	heartamount = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	sendtime = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
}

	self.__pk      = "id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_friendentity"
	return self
end

return cls