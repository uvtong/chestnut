local s = [[
local assert = assert
local type   = type
local entity = require "entity"
local modelmgr = require "modelmgr"

local _M     = {}
setmetatable(_M, modelmgr)
_M.__data    = {}
_M.__count   = 0
_M.__cap     = 0
_M.__tname   = "%s"
_M.__head    = %s
_M.__pk      = "%s"

function _M.create( ... )
	-- body
end

function _M.create(P)
	assert(P)
	local t = { 
		__head  = _M.__head,
		__tname = _M.__tname,
		__col_num_ued=0,
		__fields = %s
	}
	setmetatable(t, entity)
	for k,v in pairs(t.__fields) do
		t[k] = assert(P[k])
	end
	return t
end	

function _M.( . )
	-- body
end

function _M:add(u)
 	-- body
 	assert(u)
 	assert(self.__data[u.id] == nil)
 	self.__data[u.id] = u
 	self.__count = self.__count + 1
 	u:insert()
end

function _M:get(pk)
	-- body
	if self.__data[pk] then
		return self.__data[pk]
	elseif 
end

function _M:get_by_csv_id(csv_id)
	-- body
	return self.__data[csv_id]
end

function _M:delete_by_csv_id(csv_id)
	assert(self.__data[csv_id])
	self.__data[csv_id] = nil
	self.__count = self.__count - 1
end

function _M:get_count()
	-- body
	return self.__count
end

function _M:get_cap()
	-- body
	return self.__cap
end

function _M:clear()
	-- body
	self.__data = {}
	self.__count = 0
end

return _M
]]

return s
