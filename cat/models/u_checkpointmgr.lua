local skynet = require "skynet"
local util = require "util"

local _M = {}
_M.__data = {}
_M.__count = 0
_M.__user_id = 0

local _Meta = { g_checkpoint_id=0, passed=0}

_Meta.__tname = "u_checkpoint"

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
			t[k] = self[k]
		end
	end
	skynet.send(util.random_db(), "lua", "command", "insert", self.__tname, t)
end

function _Meta:__update_db(t)
	-- body
	-- assert(type(t) == "table")
	-- local columns = {}
	-- for i,v in ipairs(t) do
	-- 	columns[tostring(v)] = self[tostring(v)]
	-- end
	-- skynet.send(util.random_db(), "lua", "command", "update", self.__tname, {{ id = self.id }}, columns)
end

function _Meta:__serialize()
	-- body
	local r = {}
	for k,v in pairs(_Meta) do
		if not string.match(k, "^__*") then
			r[k] = self[k]
		end
	end
	return r
end

function _M:clear()
	self.__data = {}
end

function _M:update_db()
	-- body
	-- local columns = { "finished", "reward_collected", "is_unlock"}
	-- local condition = { {user_id = self.__user_id}, {csv_id = {}}}
	-- skynet.send(util.random_db(), "lua", "command", "update_all", _Meta.__tname, condition, columns, self.__data)
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
	for k,v in pairs(self.__data) do
		if v.csv_id == csv_id then
			return v
		end
	end
end

function _M:get_count()
	-- body
	return self.__count
end

return _M
