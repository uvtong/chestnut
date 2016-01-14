--dbop = require "dbop"

usermgr = {}

usermgr._data = {}

function usermgr:add( u )
	-- body
	table.insert( _data, u.id, u )
end

function usermgr:delete( id )
	-- body
	table.remove(_data, id)
end

function usermgr:find( id )
	-- body
	return self._data[id]
end

local user = { _nickname , _id }

--user._nickname = nil
--user._id = nil

function user.new( ... )
 	-- body
 	local d = { ... }
 	for k,v in pairs(d) do
 		print(k,v)
 	end
 	local t = {}
 	setmetatable( t, { __index = user } )
 	return t
 end 

function user:nickname( ... )
	-- body
	return self._nickname
end

function user:id( ... )
	return self._id
end


function user:setnickname( name )
	self._nickname = name
end

function user:setid( id )
	self._id = id
end
function user:selectdb( tvals )
	
	--return dbop.tselect( tvals )
	
end
	
local n = { nickname = "aaa"}
local u = user.new()
local t = user.new()

print( u:nickname())
print( t:nickname() )
print( u:id() )
print( t:id() )
u:setnickname( "bb")
t:setid( 4 )
print( u:nickname())
print( t:nickname() )
print( u:id() )
print( t:id() )
