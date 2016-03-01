local skynet = require "skynet"
local util = require "util"

local _M = {}
_M.__data = {}
_M.__count = 0

<<<<<<< HEAD
local _Meta = { user_id=0, star=0, upgrade_star_prop_csv_id=0, csv_id=0 , k_csv_id1 = 0 , k_csv_id2 = 0 , k_csv_id3 = 0 , k_csv_id4 = 0 , k_csv_id5 = 0 ,
				k_csv_id6 = 0 , k_csv_id7 = 0 }
=======
local _Meta = { user_id=0, csv_id=0, name=0, star=0, us_prop_csv_id=0, us_prop_num=0, sharp=0, skill_csv_id=0, gather_buffer_id=0, battle_buffer_id=0}
>>>>>>> e99e8d82c9b88aae7775b4620a0d2423b90c380a

_Meta.__tname = "u_role"

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
	skynet.send(util.random_db(), "lua", "command", "update", self.__tname, {{ user_id = self.user_id, csv_id=self.csv_id }}, columns)
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

function _M:add(u)
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

function _M:get_count()
	-- body
	return self.__count
end

return _M
