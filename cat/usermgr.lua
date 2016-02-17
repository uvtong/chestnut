local usermgr = {}
usermgr._data = {}

local user = { id, uname, uviplevel , uexp, config_sound, config_music, avatar, sign, c_role_id, ifonline, level, combat, defense, critical_hit, modify_uname_count, recharge_total, recharge_vip, rolemgr, achievementmgr, propmgr, emailbox, u_recharge_reward , onlinetime}

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
	u.uname = tvals["uname"]
	u.uviplevel = tvals["uviplevel"]
	u.uexp = tvals["uexp"]
	u.config_sound = tvals["config_sound"] and true or false
	u.config_music = tvals["config_music"] and true or false
	u.avatar = tvals["avatar"]
	u.sign = tvals["sign"]
	u.c_role_id = tvals["c_role_id"]
	u.ifonline = true
	u.level = tvals["level"]
	u.combat = tvals["combat"]
	u.defense = tvals["defense"]
	u.critical_hit = tvals["critical_hit"]
	u.modify_uname_count = tvals["modify_uname_count"]
	u.recharge_total = tvals["recharge_total"]
	u.recharge_vip = tvals["recharge_vip"]
	u.recharge_progress = tvals["recharge_progress"]
	u.recharge_diamond = tvals["recharge_diamond"]
	u.onlinetime = tvals.onlinetime
	print(u.recharge_total)
	print(u.recharge_vip)
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
	
	self._data[tostring( u.id )] = u
end

return usermgr