local skynet = require "skynet"
local util = require "util"

local _M = {}
_M.__data = {}
_M.__count = 0
_M.__user_id = 0
_M.__tname = "u_achievement"

local _Meta = { user_id=0, csv_id=0, type=0, finished=0, c_num=0, unlock_next_csv_id=0, is_unlock=0, is_valid=0}

_Meta.__tname = "u_achievement"

function _Meta.__new()
 	-- body
 	local t = {}
 	setmetatable( t, { __index = _Meta } )
 	return t
end 

function _Meta:__insert_db(priority)
	-- body
	local t = {}
	for k,v in pairs(self) do
		if not string.match(k, "^__*") then
			t[k] = assert(self[k])
		end
	end
	skynet.send(util.random_db(), "lua", "command", "insert", self.__tname, t, priority)
end

function _Meta:__update_db(t)
	-- body
	-- assert(type(t) == "table")
	-- local columns = {}
	-- for i,v in ipairs(t) do
	-- 	columns[tostring(v)] = assert(self[tostring(v)])
	-- end
	-- skynet.send(util.random_db(), "lua", "command", "update", self.__tname, {{ user_id = self.user_id, type=self.type }}, columns)
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

function _M.insert_db( values, priority )
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
	skynet.send( util.random_db() , "lua" , "command" , "insert_all" , _Meta.__tname , total, priority)
end 

function _M:update_db(priority)
	-- body
	local columns = { "type", "finished", "c_num", "unlock_next_csv_id", "is_unlock", "is_valid"}
	local condition = { {user_id = self.__user_id}, {csv_id = {}}}
	skynet.send(util.random_db(), "lua", "command", "update_all", _Meta.__tname, condition, columns, self.__data, priority)
end

function _M:clear()
	self.__data = {}
end

function _M.create( P )
	assert(P)
	local u = _Meta.__new()
	for k,v in pairs(_Meta) do
		if not string.match(k, "^__*") then
			u[k] = assert(P[k])
		end
	end
	_M.__user_id = u.user_id
	return u
end	

function _M:add( u )
	assert(u)
	self.__data[tostring(u.type)] = u
	self.__count = self.__count + 1
end

function _M:clear()
	self.__data = {}
end

function _M:get_by_type(type)
	-- body
	return self.__data[tostring(type)]
end

function _M:delete_by_type(type)
	-- body
	self.__data[tostring(type)] = nil
	self.__count = self.__count - 1
end

function _M:get_count()
	-- body
	return self.__count
end

return _M

