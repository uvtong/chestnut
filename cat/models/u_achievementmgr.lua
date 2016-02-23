local skynet = require "skynet"
local util = require "util"

local _M = {}
_M.__data = {}
_M.__count = 0

local _Meta = { user_id=0, csv_id=0, type=0, finished=0, c_num=0, unlock_next_csv_id=0, is_unlock=0, is_valid=0}

_Meta.__tname = "u_achievement"

function _Meta.__new()
 	-- body
 	local t = {}
 	setmetatable( t, { __index = _Meta } )
 	return t
end 

function _Meta:__insert_db()
	-- body
	local t = {}
	for k,v in pairs(self) do
		if not string.match(k, "^__*") then
			t[k] = assert(self[k])
		end
	end
	skynet.send(util.random_db(), "lua", "command", "insert", self.__tname, t)
end

function _Meta:__update_db(t)
	-- body
	assert(type(t) == "table")
	local columns = {}
	for i,v in ipairs(t) do
		columns[tostring(v)] = assert(self[tostring(v)])
	end
	skynet.send(util.random_db(), "lua", "command", "update", self.__tname, {{ user_id = self.user_id, type=self.type }}, columns)
end

function _Meta:__serialize()
	-- body
	local r = {}
	for k,v in pairs(_Meta) do
		if not string.match(k, "^__*") then
			r[k] = assert(self[k])
		end
	end
	return r
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
	self.__data[tostring(u.csv_id)] = u
	self.__count = self.__count + 1
end

function _M:get_by_csv_id(csv_id)
	-- body
	return self.__data[tostring(csv_id)]
end

function _M:delete_by_csv_id(csv_id)
	-- body
	assert(self.__data[tostring(csv_id)])
	self.__data[tostring(csv_id)] = nil
	self.__count = self.__count - 1
end

function _M:get_by_type(type)
	-- body
	local r = {}
	local idx = 1
	for k,v in pairs(self.__data) do
		if v.type == type then
			r[idx] = v
			idx = idx + 1
		end
	end
	return r
end

function _M:delete_by_type(type)
	-- body
	for k,v in pairs(self.__data) do
		if v.type == type then
			self.__data[k] = nil
			self.__count = self.__count - 1
			return
		end
	end
end

function _M:get_count()
	-- body
	return self.__count
end

return _M

