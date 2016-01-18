local usermgr = {}
usermgr._data = {}

local user = { id , uviplevel , uexp , config_sound, config_music, avatar, sign, c_role_id, role_list }

function user.new( ... )
 	-- body
 	local t = {}
 	setmetatable( t, { __index = user } )
 	return t
end 

function usermgr:create( tvals )
	assert(tvals)
	
	local u = user:new()
	u.id = tvals["id"]
	u.uviplevel = tvals["uviplevel"]
	u.uexp = tvals["uexp"]
	u.config_sound = tvals["config_sound"]
	u.config_music = tvals["config_music"]
	u.avatar = tvals["avatar"]
	u.sign = tvals["sign"]
	u.c_role_id = 1
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

function usermgr:add( u )
	
	if nil == u then
		--skynet.error( string.format("new user is nil in user:add\n" ) )
		print("try to add a nil value\n")
	end
	if nil ~= self._data[tostring(u._id)] then
		--skynet.error( string.format( "user already exists : id '%s'" , u.id ) )
		print( "add successfully\n")
	end

	--table.insert( self._data, u.id, u )
	--TODO     user;s roleid should be dealed with here
end

return usermgr