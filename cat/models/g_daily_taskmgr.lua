local skynet = require "skynet"
local util = require "util"

local _M = {}
_M.__data = {}
_M.__count = 0

-- type = daily_type * 10 + exercise_type
local _Meta = { update_time = 0 , type = 0 , task_name = 0 , cost_amount = 0 , iconid = 0 , basic_reward = 0 , levelup_reward = 0 , level_up = 0 , cost_id = 0 }

_M.__tname = "g_daily_task"

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
	self.__data[tostring(u.type)] = u
	self.__count = self.__count + 1
end
	
function _M:get_by_type( type )
	-- body
	return self.__data[ tostring( type ) ]
end

function _M:get_one()
	for k , v in pairs( self.__data ) do
		return v
	end
end

function _M:delete_by_type( type )
	-- body
	assert(self.__data[tostring( type )])
	self.__data[tostring( type )] = nil
	self.__count = self.__count - 1
end

function _M:get_count()
	-- body
	return self.__count
end

return _M

