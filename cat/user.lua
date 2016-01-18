--dbop = require "dbop"
--skynet = require "skynet"

usermgr = {}

usermgr._data = {}

function usermgr:add( u )
	
	if nil == u then
		--skynet.error( string.format("new user is nil in user:add\n" ) )
		print("try to add a nil value"\n)
	end
	if nil ~= self._data[tostring(u._id)] then
		--skynet.error( string.format( "user already exists : id '%s'" , u.id ) )
		print( "add successfully\n")
	end

	--table.insert( self._data, u.id, u )
	--TODO     user;s roleid should be dealed with here
end

function usermgr:create( tvals )
	local u = user.new()
	u._id = 1
	( self._data )[ tostring( u._id ) ]
	print( "add user successfully!" )
	return u
end

function usermgr:delete( id )
	if nil ~= self._data[id] then
		table.remove(self._data, id)
		-- TODO   delete user data and relative roles data in database
	end
end

function usermgr:find( id )
	local uid = tostring( id )
	return self._data[uid]
end

local user = { _id }

function user.new( ... )
 	-- body
 	local t = {}
 	setmetatable( t, { __index = user } )
 	return t
end 

--[[function user:nickname( ... )
	-- body
	return self._nickname
end 
	
function user:selectdb( tvals )
	
	--return dbop.tselect( tvals )
	
end

function user:insert
	
local n = { nickname = "aaa"}
local u = user.new(n)
print(u:nickname())--]]

return usermgr
