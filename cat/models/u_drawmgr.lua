local skynet = require "skynet"
local util = require "util"
    
local _M = {}
_M.__data = {}
_M.__count = 0
    
local _Meta = { uid = 0 , drawtype = 0 , srecvtime = 0 , propid = 0 , amount = 0 , iffree = 0 }
    
_Meta.__tname = "u_new_draw"
    
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
	skynet.send(util.random_db(), "lua", "command", "insert", self.__tname, t )
end 
    
function _Meta:__update_db(t)
	-- body
	assert(type(t) == "table")
	local columns = {}
	for i,v in ipairs(t) do
		columns[tostring(v)] = self[tostring(v)]
	end
	skynet.send(util.random_db(), "lua", "command", "update", self.__tname, { { uid = assert( self.uid ) , drawtype = self.drawtype } } , columns )
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
			u[ k ] = assert( P[ k ] )
		end
	end
	return u
end	

function _M:add( u )
	assert( u )
	self.__data[ tostring( u.drawtype )] = u
	self.__count = self.__count + 1
end
	
function _M:get_by_type( drawtype )
	-- body
	return self.__data[ tostring( drawtype ) ]
end

function _M:delete_by_type( drawtype )
	-- body
	assert(self.__data[ tostring( drawtype ) ] )
	self.__data[ tostring( drawtype ) ] = nil
	self.__count = self.__count - 1
end

function _M:get_count()
	-- body
	return self.__count
end

return _M

