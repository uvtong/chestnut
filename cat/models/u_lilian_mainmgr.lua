local skynet = require "skynet"
local util = require "util"

local _M = {}
_M.__data = {}
_M.__count = 0

local _Meta = { 
			   	user_id = 0 , 
				csv_id = 0 ,
				quanguan_id = 0 ,
				start_time = 0 ,
				end_time = 0 ,
				if_trigger_event = 0 ,
				iffinished = 0,
				invitation_id = 0 ,
				iflevel_up = 0 ,
				event_start_time = 0,
				event_end_time = 0,
				if_lilian_finished = 0 ,
				eventid = 0
			  }

_Meta.__tname = "u_lilian_main"

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

function _Meta:__update_db(t , priority)
	-- body
	assert(type(t) == "table")
	local columns = {}
	for i,v in ipairs(t) do
		columns[tostring(v)] = self[tostring(v)]
	end
	local sql = util.update(self.__tname, {{ user_id =self.user_id, csv_id = self.csv_id }}, columns)
	skynet.send(util.random_db(), "lua", "command", "update_sql", self.__tname, sql, priority)
	-- skynet.send(util.random_db(), "lua", "command", "update", self.__tname, {{ csv_id=assert(self.csv_id) }}, columns , priority)
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
			print( k , v , P[k] )
			u[k] = assert(P[k])
		end
	end
	return u
end	

function _M:add( u )
	assert(u)
	self.__data[tostring(u.quanguan_id)] = u
	self.__count = self.__count + 1
end 
	
function _M:get_by_csv_id(quanguan_id)
	-- body
	return self.__data[tostring(quanguan_id)]
end

function _M:delete_by_csv_id(quanguan_id)
	-- body
	assert(self.__data[tostring(quanguan_id)])
	self.__data[tostring(quanguan_id)] = nil
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
	-- 	local columns = { "if_lilian_finished" , "iffinished" }
	-- 	local condition = { { user_id = self.__user_id } , { csv_id = {} } }
	-- 	skynet.send(util.random_db(), "lua", "command", "update_all", _Meta.__tname, condition, columns, self.__data, priority)
	-- end
end

return _M

