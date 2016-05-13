local skynet = require "skynet"
local util = require "util"
local const = require "const"
local notification = require "notification"
local query = require "query"

local _M = {}
_M.__data = {}
_M.__count = 0
_M.__user_id = 0
_M.__tname = "u_prop"

local _Meta = { user_id=0, 
				csv_id=0, 
				num=0, 
				sub_type=0, 
				level=0, 
				pram1=0, 
				pram2=0, 
				use_type=0}
_Meta.__tname = "u_prop"

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
	query.write(".db", self.__tname, sql, priority)
end

function _Meta:__update_db(t)
	-- body
	-- assert(type(t) == "table")
	-- local columns = {}
	-- for i,v in ipairs(t) do
	-- 	columns[tostring(v)] = self[tostring(v)]
	-- end
	-- skynet.send(util.random_db(), "lua", "command", "update", self.__tname, {{ user_id = self.user_id,  csv_id = self.csv_id}}, columns)
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
	local sql = util.insert_all(_Meta.__tname, total)
	query.write(".db", _M.__tname, sql, priority)
end 

-- pk
function _M.create_with_csv_id(csv_id) 
	-- body
	assert(csv_id, "csv_id ~= nil")
	local r = skynet.call(".game", "lua", "query_g_prop", csv_id)
	assert(r, "there is no corresponding props.")
	r.user_id = _M.__user_id
	r.num = 0
	return _M.create(r)
end

function _M.create(P)
	assert(P)
	local u = _Meta.__new()
	for k,v in pairs(_Meta) do
		if not string.match(k, "^__*") then
			-- print(k, P.csv_id)
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
	self.__data[tostring(csv_id)] = nil
end

function _M:get_count()
	-- body
	return self.__count
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
		local columns = { "num" }
		local condition = { {user_id = self.__user_id}, {csv_id = {}}}
		local sql = util.update_all(self.__tname, condition, columns, self.__data)
		query.write(".db", self.__tname, sql, priority)
	end
end

return _M
