local skynet = require "skynet"
local util = require "util"

local _M = {}
_M.__data = {}
_M.__count = 0
_M.__user_id = 0
_M.__tname = "u_journal"

local _Meta = { user_id=0, date=0, goods_refresh_count=0, goods_refresh_reset_count=0}

_Meta.__tname = "u_journal"

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
	skynet.send(util.random_db(), "lua", "command", "insert", self.__tname, t, priority)
end

function _Meta:__update_db(t)
	-- body
	-- assert(type(t) == "table")
	-- local columns = {}
	-- for i,v in ipairs(t) do
	-- 	columns[tostring(v)] = self[tostring(v)]
	-- end
	-- skynet.send(util.random_db(), "lua", "command", "update", self.__tname, {{ user_id=self.user_id, date=assert(self.date) }}, columns)
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

function _M.insert_db( values, priority)
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
	self.__data[tostring(u.date)] = u
	self.__count = self.__count + 1
end

function _M:get_by_today()
	-- body
	local t = os.date("*t", os.time())
	t = { year=t.year, month=t.month, day=t.day}
	local sec = os.time(t)
	local j = self:get_by_date(sec)
	if j then
		return j
	else
		t = { user_id=user.csv_id, date=sec, goods_refresh_count=0, goods_refresh_reset_count=0}
		j = self.create(t)
		self:add(j)
		j:__insert_db(const.DB_PRIORITY_1)
		return j
	end
end

function _M:get_by_date(csv_id)
	-- body
	return self.__data[tostring(csv_id)]
end

function _M:delete_by_date(csv_id)
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
		local columns = { "goods_refresh_count", "goods_refresh_reset_count"}
		local condition = { {user_id = self.__user_id}, {date = {}}}
		skynet.send(util.random_db(), "lua", "command", "update_all", _Meta.__tname, condition, columns, self.__data, priority)
	end
end

return _M

