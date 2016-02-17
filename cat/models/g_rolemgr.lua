local skynet = require "skynet"
local util = require "util"

local _M = {}
_M.__data = {}
_M.__count = 0

local _Meta = { csv_id, }

_Meta.__tname = "g_role"

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
	assert(type(t) == "table")
	local columns = {}
	for i,v in ipairs(t) do
		columns[tostring(v)] = self[tostring(v)]
	end
	skynet.send(util.random_db(), "lua", "command", "update", self.__tname, {{ id = self.id }}, columns)
end

function _M.create( P )
	assert(P)
	local u = _Meta.__new()
	for k,v in pairs(_Meta) do
		if not string.match(k, "^__*") then
			u[k] = P[k]
		end
	end
	return u
end	

function _M:add( u )
	assert(u)
	self.__data[tostring(u.id)] = u
	self.__count = self.__count + 1
end
	
function _M:delete(id)
	assert(id)
	self.__data[tostring(id)] = nil
end

function _M:get(id)
	-- body
	return self.__data[tostring(id)]
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

function _M:insert_db(r)
	-- body
	local t = {}
	t.csv_id = r.csv_id
	skynet.send(util.random_db(), "lua", "command", "insert", self.__tname, t)
end

function _M:update_db(r, t)
	-- body
	skynet.send(util.random_db(), "lua", "command", "update", self.__tname, {{ user_id = t.user_id }}, t)
end

return _M
