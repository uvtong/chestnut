local s = [[
local skynet = require "skynet"
local entity = require "entity"
local modelmgr = require "modelmgr"
local assert = assert
local type   = type
local setmetatable = setmetatable

local _M = {}

function _M.new( ... )
	-- body
	local _M     = setmetatable({}, modelmgr)
	_M.__data    = {}
	_M.__count   = 0
	_M.__cap     = 0
	_M.__tname   = "%s"
	_M.__head    = %s
	_M.__pk      = "%s"
	_M.__fk      = "%s"
	_M.__rdb     = skynet.localname(skynet.getenv("gated_rdb"))
	_M.__wdb     = skynet.localname(skynet.getenv("gated_wdb"))
	_M.__stm     = false
	return _M
end

function _M.genpk(self, user_id, csv_id)
	-- body
	local pk = user_id << 32
	pk = (pk | ((1 << 32 -1) & csv_id ))
	return pk
end

function _M.add(self, u)
 	-- body
 	assert(u)
 	assert(self.__data[u.id] == nil)
 	self.__data[ u[self.__pk] ] = u
 	self.__count = self.__count + 1
end

function _M.get(self, pk)
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

function _M.delete(self, pk)
	-- body
	local r = self.__data[pk]
	if r then
		r("update")
		self.__data[pk] = nil
	end
end

function _M.get_by_csv_id(self, csv_id)
	-- body
	return self.__data[csv_id]
end

function _M.delete_by_csv_id(self, csv_id)
	assert(self.__data[csv_id])
	self.__data[csv_id] = nil
	self.__count = self.__count - 1
end

function _M.get_count(self)
	-- body
	return self.__count
end

function _M.get_cap(self)
	-- body
	return self.__cap
end

function _M.clear(self)
	-- body
	self.__data = {}
	self.__count = 0
end

return _M

]]

return s
