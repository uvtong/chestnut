local usermgr = {}
usermgr._data = {}

local user = { id, uname, uviplevel , uexp, config_sound, config_music, avatar, sign, c_role_id, ifonline, level, combat, defense, critical_hit, rolemgr, achievementmgr, propmgr, emailbox }

function user.new( ... )
 	-- body
 	local t = {}
 	setmetatable( t, { __index = user } )
 	return t
end 

function usermgr.create( tvals )
	assert(tvals)
	local u = user.new()
	u.id = tvals["id"]
	u.uviplevel = tvals["uviplevel"]
	u.uexp = tvals["uexp"]
	u.config_sound = tvals["config_sound"]
	u.config_music = tvals["config_music"]
	u.avatar = tvals["avatar"]
	u.sign = tvals["sign"]
	u.c_role_id = tvals["c_role_id"]
	u.ifonline = false
	u.level = tvals["level"]
	u.combat = tvals["combat"]
	u.defense = tvals["defense"]
	u.critical_hit = tvals["critical_hit"]
	return u
end	
	
function usermgr:delete( id )
	if nil ~= self._data[tostring(id)] then
		table.remove(self._data, id)
		-- TODO   delete user data and relative roles data in database
	end
end

function usermgr:find( id )
	local uid = tostring( id )
	return self._data[uid]
end

function usermgr:add( u )
	assert(u)
	self._data[string.format("%d", u.id)] = u
end

return usermgr