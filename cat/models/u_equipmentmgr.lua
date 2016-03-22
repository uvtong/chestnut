local skynet = require "skynet"
local util = require "util"

local _M = {}
_M.__data = {}
_M.__count = 0
_M.__user_id = 0
_M.__tname = "u_equipment"

local _Meta = { user_id=0, 
				csv_id=0, 
				level=0, 
				combat=0, 
				defense=0, 
				critical_hit=0, 
				king=0, 
				critical_hit_probability=0, 
				combat_probability=0, 
				defense_probability=0, 
				king_probability=0, 
				enhance_success_rate=0, 
				currency_type=0, 
				currency_num=0}

_Meta.__tname = "u_equipment"

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
			t[k] = self[k]
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
	-- skynet.send(util.random_db(), "lua", "command", "update", self.__tname, {{ user_id=self.user_id, csv_id=self.csv_id }}, columns)
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

function _M.insert_db( values )
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
	skynet.send(util.random_db() , "lua" , "command" , "insert_all" , _Meta.__tname , total)
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
	return u
end	

function _M:add( u )
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

function _M:update_db(priority)
	-- body
	local columns = { "level", "combat", "defense", "critical_hit", "king", "critical_hit_probability", "combat_probability", 
				"defense_probability", "king_probability", "enhance_success_rate", "currency_type", "currency_num"}
	local condition = { {user_id = self.__user_id}, {csv_id = {}}}
	skynet.send(util.random_db(), "lua", "command", "update_all", _Meta.__tname, condition, columns, self.__data, priority)
end

return _M
