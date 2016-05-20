local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("u_lilian_submgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "u_lilian_sub"
	self.__head    = {
	id = {
		pk = true,
		fk = false,
		uq = false,
		t = "number",
	},
	csv_id = {
		pk = false,
		fk = true,
		uq = false,
		t = "number",
	},
	first_lilian_time = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	start_time = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	update_time = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	used_queue_num = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	end_lilian_time = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
}

	self.__pk      = "id"
	self.__fk      = "csv_id"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "u_lilian_subentity"
	return self
end

return cls