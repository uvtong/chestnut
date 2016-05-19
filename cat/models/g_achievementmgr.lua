local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("g_achievementmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_achievement"
	self.__head    = {
	csv_id = {
		pk = true,
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
	name = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
	c_num = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	describe = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
	icon_id = {
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
	star = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
	unlock_next_csv_id = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
}

	self.__pk      = "csv_id"
	self.__fk      = "0"
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_achievemententity"
	return self
end

function cls.genpk(self, user_id, csv_id)
	-- body
	local pk = user_id << 32
	pk = (pk | ((1 << 32 -1) & csv_id ))
	return pk
end

function cls.add(self, u)
 	-- body
 	assert(u)
 	assert(self.__data[u.id] == nil)
 	self.__data[ u[self.__pk] ] = u
 	self.__count = self.__count + 1
end

function cls.get(self, pk)
	-- body
	if self.__data[pk] then
		return self.__data[pk]
	else
		local r = self("load", pk)
		if r then
			self.create(r)
			self:add(r)
		end
		return r
	end
end

function cls.delete(self, pk)
	-- body
	local r = self.__data[pk]
	if r then
		r("update")
		self.__data[pk] = nil
	end
end

function cls.get_by_csv_id(self, csv_id)
	-- body
	return self.__data[csv_id]
end

function cls.delete_by_csv_id(self, csv_id)
	assert(self.__data[csv_id])
	self.__data[csv_id] = nil
	self.__count = self.__count - 1
end

function cls.get_count(self)
	-- body
	return self.__count
end

function cls.get_cap(self)
	-- body
	return self.__cap
end

function cls.clear(self)
	-- body
	self.__data = {}
	self.__count = 0
end

return cls