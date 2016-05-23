local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
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
		cn = "id",
		uq = false,
		t = "number",
	},
	csv_id = {
		pk = false,
		fk = false,
		cn = "csv_id",
		uq = false,
		t = "number",
	},
	uid = {
		pk = false,
		fk = true,
		cn = "uid",
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
	title = {
		pk = false,
		fk = false,
		cn = "title",
		uq = false,
		t = "string",
	},
	content = {
		pk = false,
		fk = false,
		cn = "content",
		uq = false,
		t = "string",
	},
	acctime = {
		pk = false,
		fk = false,
		cn = "acctime",
		uq = false,
		t = "number",
	},
	deltime = {
		pk = false,
		fk = false,
		cn = "deltime",
		uq = false,
		t = "number",
	},
	isread = {
		pk = false,
		fk = false,
		cn = "isread",
		uq = false,
		t = "number",
	},
	isdel = {
		pk = false,
		fk = false,
		cn = "isdel",
		uq = false,
		t = "number",
	},
	itemsn1 = {
		pk = false,
		fk = false,
		cn = "itemsn1",
		uq = false,
		t = "number",
	},
	itemnum1 = {
		pk = false,
		fk = false,
		cn = "itemnum1",
		uq = false,
		t = "number",
	},
	itemsn2 = {
		pk = false,
		fk = false,
		cn = "itemsn2",
		uq = false,
		t = "number",
	},
	itemnum2 = {
		pk = false,
		fk = false,
		cn = "itemnum2",
		uq = false,
		t = "number",
	},
	itemsn3 = {
		pk = false,
		fk = false,
		cn = "itemsn3",
		uq = false,
		t = "number",
	},
	itemnum3 = {
		pk = false,
		fk = false,
		cn = "itemnum3",
		uq = false,
		t = "number",
	},
	itemsn4 = {
		pk = false,
		fk = false,
		cn = "itemsn4",
		uq = false,
		t = "number",
	},
	itemnum4 = {
		pk = false,
		fk = false,
		cn = "itemnum4",
		uq = false,
		t = "number",
	},
	itemsn5 = {
		pk = false,
		fk = false,
		cn = "itemsn5",
		uq = false,
		t = "number",
	},
	itemnum5 = {
		pk = false,
		fk = false,
		cn = "itemnum5",
		uq = false,
		t = "number",
	},
	isreward = {
		pk = false,
		fk = false,
		cn = "isreward",
		uq = false,
		t = "number",
	},
}

	self.__head_ord = {}
		self.__head_ord[1] = self.__head["id"]
	self.__head_ord[2] = self.__head["csv_id"]
	self.__head_ord[3] = self.__head["uid"]
	self.__head_ord[4] = self.__head["type"]
	self.__head_ord[5] = self.__head["title"]
	self.__head_ord[6] = self.__head["content"]
	self.__head_ord[7] = self.__head["acctime"]
	self.__head_ord[8] = self.__head["deltime"]
	self.__head_ord[9] = self.__head["isread"]
	self.__head_ord[10] = self.__head["isdel"]
	self.__head_ord[11] = self.__head["itemsn1"]
	self.__head_ord[12] = self.__head["itemnum1"]
	self.__head_ord[13] = self.__head["itemsn2"]
	self.__head_ord[14] = self.__head["itemnum2"]
	self.__head_ord[15] = self.__head["itemsn3"]
	self.__head_ord[16] = self.__head["itemnum3"]
	self.__head_ord[17] = self.__head["itemsn4"]
	self.__head_ord[18] = self.__head["itemnum4"]
	self.__head_ord[19] = self.__head["itemsn5"]
	self.__head_ord[20] = self.__head["itemnum5"]
	self.__head_ord[21] = self.__head["isreward"]

	self.__pk      = "id"
	self.__fk      = "uid"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_new_emailentity"
	return self
end

return cls