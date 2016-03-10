local _M = {}
_M.__data = {}
_M.__count = 0

local _Meta = {}

function _Meta.new()
 	-- body
 	local t = {}
 	setmetatable( t, { __index = _Meta } )
 	return t
end 

function _M:clear()
	self.__data = {}
end

function _M.create( P )
	assert(_M.__count < 1)
	local u = _Meta.new()
	_M.__count = _M.__count + 1
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

function _M:get_count()
	-- body
	return self.__count
end

return _M
