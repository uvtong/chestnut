local skynet = require "skynet"
local util = require "util"

local _M = {}
_M.__data = {}
_M.__count = 0

local _Meta = { id = 0 , val = 0 , step = 0 }

_Meta.__tname = "randomval"

function _Meta.__new()
 	-- body
 	local t = {}
 	setmetatable( t, { __index = _Meta } )
 	return t
end 

function _Meta:__insert_db()
	-- body
	local t = {}
	for k,v in pairs( _Meta ) do
		if not string.match(k, "^__*") then
			t[ k ] = assert( self[ k ] )
		end
	end
	skynet.send( util.random_db() , "lua" , "command" , "insert" , self.__tname , t )
end

function _Meta:__update_db( t )
	-- body
	assert( type( t ) == "table" )
	local columns = {}
	for i,v in ipairs( t ) do
		columns[ tostring( v ) ] = self[ tostring( v ) ]
	end
	skynet.send( util.random_db(), "lua", "command", "update", self.__tname, { { id = assert( self.id ) } } , columns )
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

function _M:clear()
	self.__data = {}
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
	skynet.send( util.random_db() , "lua" , "command" , "insert_all" , _Meta.__tname , total )
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
	self.__data[tostring(u.id)] = u
	self.__count = self.__count + 1
end
	
function _M:get_by_id(id)
	-- body
	return self.__data[tostring(id)]
end

function _M:delete_by_id(id)
	-- body
	assert(self.__data[tostring(id)])
	self.__data[tostring(id)] = nil
	self.__count = self.__count - 1
end

function _M:get_count()
	-- body
	return self.__count
end

return _M

