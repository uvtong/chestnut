local skynet = require "skynet"
local util = require "util"
local notification = require "notification"

local _M = {}
_M.__data = {}
_M.__count = 0
_M.__cap = 0
_M.__user_id = 0
_M.__tname = "arena"

local _Meta = "{ user_id=0, csv_id=0, }"

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
	local sql = util.insert(self.__tname, t)
	skynet.send(util.random_db(), "lua", "command", "insert_sql", _M.__tname, sql, priority)
end

function _Meta:__update_db(t, priority)
	-- body
	-- assert(type(t) == "table")
	-- local columns = {}
	-- for i,v in ipairs(t) do
	-- 	columns[tostring(v)] = self[tostring(v)]
	-- end
	-- local sql = util.insert(self.__tname, {{ user_id=self.user_id, csv_id=self.csv_id }}, columns)
	-- skynet.send(util.random_db(), "lua", "command", "update_sql", _M.__tname, sql, priority)
end

function _Meta:__get(key)
	-- body
	assert(type(key) == "string")
	assert(_Meta[key])
	return assert(self[key])
end

function _Meta:__set(key, value)
	-- body
	assert(type(key) == "string")
	self[key] = value
	if self[csv_id] == const.GOLD then
		notification.handler[self.EGOLD](self.EGOLD)
	elseif self[csv_id] == const.EXP then
		notification.handler[self.EEXP](self.EGOLD)
	else
	end
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
	local sql = util.insert_all(_M.__tname, total)
	skynet.send(util.random_db(), "lua", "command", "insert_all_sql", _M.__tname, sql, priority)
end 

function _M.create_with_csv_id(csv_id)
 	-- body
 	assert(csv_id, "csv_id ~= nil")
 	return _M.create(r)
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
	assert(self.__data[tostring(u.csv_id)] == nil)
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

function _M:get_count()
	-- body
	return self.__count
end

function _M:get_cap()
	-- body
	return self.__cap
end

function _M:clear()
	self.__data = {}
	self.__count = 0
end

function _M:get(pk, key)
	-- body
	local r = self:get_by_csv_id(pk)
	r:__get(key)
end

function _M:set(pk, key, value)
	-- body
	local r = self:get_by_csv_id(pk)
	r:__set(key, value)
end

function _M:update_db(priority)
	-- body
	assert(priority)
	if self.__count > 0 then
		local columns = { "finished", "reward_collected", "is_unlock"}
		local condition = { {user_id = self.__user_id}, {csv_id = {}}}
		local sql = util.update_all(_M.__tname, condition, columns, self.__data)
		skynet.send(util.random_db(), "lua", "command", "update_all_sql", _M.__tname, sql, priority)
	end
end

return _M

