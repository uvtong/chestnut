local skynet = require "skynet"
local util = require "util"
local const = require "const"

local _M = {}
_M.__data = {}
_M.__count = 0
_M.__user_id = 0
_M.__tname = "u_checkpoint_rc"

local _Meta = { user_id=0, csv_id=0, passed=0, cd_starttime=0, cd_finished=0}

function _Meta.__new()
 	-- body
 	local t = {}
 	setmetatable( t, { __index = _Meta } )
 	return t
end 

function _Meta:__insert_db(priority)
	-- body
	assert(priority, "need priority")
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

function _M.create_with_csv_id(csv_id)
	-- body
	local tmp = {
		user_id = _M.__user_id,
		csv_id = csv_id,
		passed = 0,
		cd_starttime=0,
		cd_finished=0,
	}
	return _M.create(tmp)
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
	local r = self.__data[tostring(csv_id)]
	if r then
		return r
	else
		r = self.create_with_csv_id(csv_id)
		self:add(r)
		r:__insert_db(const.DB_PRIORITY_2)
		return r
	end
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
	-- assert(priority)
	-- if self.__count > 0 then
	-- 	local columns = { "passed"}
	-- 	local condition = { {user_id = self.__user_id}, {csv_id = {}}}
	-- 	skynet.send(util.random_db(), "lua", "command", "update_all", _M.__tname, condition, columns, self.__data, priority)
	-- end
end

return _M

