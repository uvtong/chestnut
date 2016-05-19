local skynet = require "skynet"
local modelmgr = require "modelmgrcpp"
local entity = require "entity"
local assert = assert
local type   = type

local cls = class("g_lilian_invitationmgr", modelmgr)

function cls:ctor( ... )
	-- body
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "g_lilian_invitation"
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
	name = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
	reward = {
		pk = false,
		fk = false,
		uq = false,
		t = "string",
	},
}

	self.__pk      = "id"
	self.__fk      = ""
	self.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	self.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	self.__stm     = false
	self.__entity  = "g_lilian_invitationentity"
	return self
end

function cls.genpk(self, csv_id)
	-- body
	if #self.__fk == 0 then
		return csv_id
	else
		local pk = user_id << 32
		pk = (pk | ((1 << 32 -1) & csv_id ))
		return pk
	end
end

function cls.add(self, u)
 	-- body
 	assert(u)
 	assert(self.__data[ u[self.__pk](u) ] == nil)
 	self.__data[ u[self.__pk](u) ] = u
 	self.__count = self.__count + 1
end

function cls.get(self, pk)
	-- body
	if self.__data[pk] then
		return self.__data[pk]
	else
		assert(false)
		-- local r = self("load", pk)
		-- if r then
		-- 	self.create(r)
		-- 	self:add(r)
		-- end
		-- return r
	end
end

function cls.delete(self, pk)
	-- body
	if nil ~= self.__data[pk] then
		self.__data[pk] = nil
		self.__count = self.__count - 1
	end
end

function cls.get_by_csv_id(self, csv_id)
	-- body
	local pk = self:genpk(csv_id)
	return self:get(pk)
end

function cls.delete_by_csv_id(self, csv_id)
	local pk = self:genpk(csv_id)
	self:delete(pk)
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