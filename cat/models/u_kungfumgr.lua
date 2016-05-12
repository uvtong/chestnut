local skynet = require "skynet"
local util = require "util"

local _M = {}
_M.__data = {}
_M.__count = 0
_M.__user_id = 0
_M.__tname = "u_kungfu"

local _Meta = { user_id = 0 , csv_id = 0 , level = 0 , type = 0 , sp_id = 0 , g_csv_id = 0} -- type 1 zhudong , 2 beidong , csv_id is quanfa leixing id = 1,2,3,4,...

_Meta.__tname = "u_kungfu"

function _Meta.__new()
 	-- body
 	local t = {}
 	setmetatable( t, { __index = _Meta } )
 	return t
end 

function _Meta:__insert_db( priority )
	-- body
	assert(priority)
	local t = {}
	for k,v in pairs(_Meta) do
		if not string.match(k, "^__*") then
			t[k] = assert(self[k])
		end
	end
	skynet.send(util.random_db(), "lua", "command", "insert", self.__tname, t , priority)
end

function _Meta:__update_db(t)
	-- body
	-- assert(type(t) == "table")
	-- local columns = {}
	-- for i,v in ipairs(t) do
	-- 	columns[tostring(v)] = self[tostring(v)]
	-- end
	-- skynet.send(util.random_db(), "lua", "command", "update", self.__tname, {{ user_id = self.user_id , r_csv_id = self.r_csv_id , k_csv_id = self.k_csv_id }},  columns)
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
	assert( u )
	self.__data[ tostring( u.csv_id ) ] = u

	self.__count = self.__count + 1
end	
		
function _M:get_by_type(type)
	-- body
	return self.__data[ tostring( type ) ] 
end	

function _M:delete_by_type(type)
	-- body
	assert(self.__data[tostring(type)])
	self.__data[tostring(type)] = nil
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
		local columns = { "level", "sp_id" }
		local condition = { {user_id = self.__user_id}, {csv_id = {}}}
		skynet.send(util.random_db(), "lua", "command", "update_all", _Meta.__tname, condition, columns, self.__data, priority)
	end
end

return _M

