local skynet = require "skynet"
local util = require "util"

local _M = {}
_M.__data = {}
_M.__count = 0

local _Meta = { g_csv_id = 0 , name = 0 , csv_id = 0 , level = 0, iconid = 0 , skill_descp = 0 , skill_effect = 0 , type = 0 , harm_type = 0 , arise_probability = 0 , arise_count = 0 , arise_type = 0 , arise_param = 0 , attack_type = 0 , effect_percent = 0 , addition_effect_type = 0 , addition_prog = 0 ,  property_csv_id = 0 , property_p = 0 , prop_csv_id = 0 , prop_num = 0 , currency_type = 0 , currency_num = 0 }

_Meta.__tname = "g_kungfu"

function _Meta.__new()
 	-- body
 	local t = {}
 	setmetatable( t, { __index = _Meta } )
 	return t
end 

function _Meta:__insert_db()
	-- body
	local t = {}
	for k,v in pairs(_Meta) do
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
		columns[tostring(v)] = self[tostring(v)]
	end
	skynet.send(util.random_db(), "lua", "command", "update", self.__tname, {{ csv_id=assert(self.csv_id) }}, columns)
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
			print(k)
			u[k] = assert(P[k])
		end
	end
	return u
end	

function _M:add( u )
	assert(u)
	self.__data[tostring(u.g_csv_id)] = u
	self.__count = self.__count + 1
end
	
function _M:get_by_g_csv_id( type , level )
	-- body
	assert( type , level )
	for k , v in pairs( self.__data ) do
		if v.level == level and v.csv_id == type then
			return v
		end
	end
end

function _M:delete_by_g_csv_id(g_csv_id)
	-- body
	assert(self.__data[tostring(g_csv_id)])
	self.__data[tostring(g_csv_id)] = nil
	self.__count = self.__count - 1
end

function _M:get_count()
	-- body
	return self.__count
end

return _M

