local skynet = require "skynet"
local util = require "util"

local _M = {}
_M.__data = {}
_M.__count = 0
_M.__user_id = 0
_M.__tname = "g_role_effect"

local _Meta = { 
		buffer_id = 0,
		property_id1 = 0,
		value1 = 0,
		property_id2 = 0,
		value2 = 0,
		property_id3 = 0,
		value3 = 0,
		property_id4 = 0,
		value4 = 0,
		property_id5 = 0,
		value5 = 0,
		property_id6 = 0,
		value6 = 0,
		property_id7 = 0,
		value7 = 0,
		property_id8 = 0,
		value8 = 0,
		 }

function _Meta.__new()
 	-- body
 	local t = {}
 	setmetatable( t, { __index = _Meta } )
 	return t
end 

function _Meta:__insert_db(priority)
	-- body
	assert(priority)
	local t = {}
	for k,v in pairs(_Meta) do
		if not string.match(k, "^__*") then
			t[k] = assert(self[k])
		end
	end
	skynet.send(util.random_db(), "lua", "command", "insert", _M.__tname, t, priority)
end

function _Meta:__update_db(t, priority)
	-- body
	-- assert(type(t) == "table")
	-- local columns = {}
	-- for i,v in ipairs(t) do
	-- 	columns[tostring(v)] = self[tostring(v)]
	-- end
	-- skynet.send(util.random_db(), "lua", "command", "update", _M.__tname, {{ user_id=self.user_id, csv_id=self.csv_id }}, columns, priority)
end

function _M.insert_db(values, priority)
	assert(priority)
	assert(type(values) == "table" )
	local total = {}
	for i,v in ipairs(values) do
		local t = {}
		for kk,vv in pairs(v) do
			if not string.match(kk, "^__*") then
				t[kk] = vv
			end
		end
		table.insert(total, t)
	end
	skynet.send(util.random_db(), "lua", "command", "insert_all", _M.__tname, total, priority)
end 

function _M.create( P )
	assert(P)
	local u = _Meta.__new()
	for k,v in pairs(_Meta) do
		if not string.match(k, "^__*") then
			u[k] = assert(P[k])
		end
	end
	return u
end	

function _M:add( u )
	assert(u)
	assert(self.__data[tostring(u.buffer_id)] == nil)
	self.__data[tostring(u.buffer_id)] = u
	self.__count = self.__count + 1
end
	
function _M:get_by_csv_id(buffer_id)
	-- body
	return self.__data[tostring(buffer_id)]
end

function _M:delete_by_csv_id(csv_id)
	-- body
	assert(self.__data[tostring(csv_id)])
	self.__data[tostring(csv_id)] = nil
	self.__count = self.__count - 1
end

function _M:get_count()
	-- body
	return self.__count
end

function _M:clear()
	self.__data = {}
	self.__count = 0
end

function _M:update_db(priority)
	-- body
	assert(priority)
	if self.__count > 0 then
		local columns = { "finished", "reward_collected", "is_unlock"}
		local condition = { {user_id = self.__user_id}, {csv_id = {}}}
		skynet.send(util.random_db(), "lua", "command", "update_all", _M.__tname, condition, columns, self.__data, priority)
	end
end

return _M

