local assert = assert
local type   = type
local entity = require "entity"
local modelmgr = require "modelmgr"

local _M     = {}
setmetatable(_M, modelmgr)
_M.__data    = {}
_M.__count   = 0
_M.__cap     = 0
_M.__user_id = 0
_M.__tname   = "area"
_M.__head    = {
	name = {
		pk = true,
		fk = false,
		uq = false,
		t = "string",
	},
	uid = {
		pk = false,
		fk = false,
		uq = false,
		t = "number",
	},
}


function _M.create(P)
	assert(P)
	local t = { 
		col_num_ued=0, 
		table_name="area", 
		fields = {
			name = { c = 0, v = nil },
			uid = { c = 0, v = nil },
		}
	}
	setmetatable(t, entity)
	for k,v in pairs(t.fields) do
		t[k] = assert(P[k])
	end
	return t
end	

function _M:add(u)
 	-- body
 	assert(u)
 	assert(self.__data[u.name] == nil)
 	self.__data[u.csv_id] = u
 	self.__count = self.__count + 1
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
