local skynet = require "skynet"
local util = require "util"

local _M = {}
_M.__data = {}
_M.__count = 0
_M.__user_id = 0
_M.__tname = "u_lilian_sub"

local _Meta = { 
				csv_id = 0 , 
				first_lilian_time = 0 , 
				start_time = 0,
				update_time = 0 , 
				used_queue_num = 0 , 
			  }

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
	table.insert( self.__data , u )
	self.__count = self.__count + 1
end 
	
function _M:get_lilian_sub()
	-- body
	return self.__data[1]
end 
	
function _M:delete_lilian_sub()
	-- body
	self.__data[1] = nil
	self.__count = self.__count - 1
end 
	
function _M:get_lilian_num_by_id( quanguan_id )
	assert( quanguan_id )

	local r = assert( self.__data[1] )
			
	for i = 1 , 5 do
		local squanguan_id = "quanguan_id" .. i
		local svalue = "value" .. i

		if r[ squanguan_id ] == quanguan_id then
			return r[ svalue ]
		end 
	end 

	return 0
end  	
		
function _M:set_num_by_quanguan_id( quanguan_id )
	assert( quanguan_id )

	local r = assert( self.__data[1] )
	local i = 1
	while i <= 5 do
		local quanguan = "quanguan_id" .. i
		local value = "value" .. i

		if r[quanguan] == quanguan_id then
			r[value] = r[value]  + 1
			break
		elseif 0 == r[quanguan] then
			r[value] = 1
			break
		else
			assert( false )
		end

		i = i + 1
	end 

	return true
end 	

function _M:reset_quanguan_num()
	local r = assert( self.__data[1] )
	local i = 1
	while i <= 5 do
		local quanguan = "quanguan_id" .. i
		local value = "value" .. i

		if r[quanguan] ~= 0 then
			r[value] = 0
		end

		i = i + 1
	end
	
	return true 
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
	-- if self.__count > 0 then
	-- 	local columns = { "first_lilian_time" , "start_time" , "update_time" , "used_queue_num" }
	-- 	local condition = { {user_id = self.__user_id} , {csv_id = {}} }
	-- 	skynet.send(util.random_db(), "lua", "command", "update_all", _M.__tname, condition, columns, self.__data, priority)
	-- end
end

return _M

