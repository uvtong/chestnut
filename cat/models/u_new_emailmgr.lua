local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("u_new_emailmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_new_email"
	self.__head    = {
	id = {
		pk = true,
		fk = false,
		uq = false,
		t = "number",
	},
	csv_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	uid = {
		pk = false,
		fk = true,
		uq = false,
		t = "number",
	},
	type = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	title = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
	content = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
	acctime = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	deltime = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	isread = {
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
	itemsn1 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	itemnum1 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	itemsn2 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	itemnum2 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	itemsn3 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	itemnum3 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	itemsn4 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	itemnum4 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	itemsn5 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	itemnum5 = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	isreward = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
}

	self.__pk      = "id"
	self.__fk      = "uid"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_new_emailentity"
	return self
end

return cls