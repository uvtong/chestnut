local rolemgr = {}
rolemgr._data = {}

local role = { id , nickname , user_id, wake_level, level , combat , defense , critical_hit , skill , c_equipment, c_dress , c_kungfu }
	
function role.new( ... )
	local t = {}
	setmetatable( t , { __index = role } )	
	return t
end	

function rolemgr:create( tvals )	
	--assert(tvals)
	if tvals == nil then
		print("tvals is nil")
		return nil
	end
	local r = role.new()
	r.id = tvals.id
	r.nickname = tvals.nickname
	r.user_id = tvals.user_id
	r.wake_level = tvals.wake_level
	r.level = tvals.level
	r.combat = tvals.combat
	r.defense = tvals.defense
	r.critical_hit = tvals.critical_hit
	r.skill = tvals.skill
	r.c_equipment = tvals.c_equipment
	r.c_dress = tvals.c_dress
	r.c_kungfu = tvals.c_kungfu
	return r
end

function rolemgr:find( roleid )
	for k,v in pairs(self._data) do
		print(k,v)
	end
	return rolemgr._data[tostring(roleid)]
end	

function rolemgr:add( role )
	-- body
	print "rolemgr add"
	for k,v in pairs(role) do
		print(k,v)
	end
	print(tostring(role.id))

	(self._data)[tostring(role.id)] = role
	id = tostring(role.id)
	return (rolemgr._data)[ id ]
end	

function rolemgr:remove( roleid )
	rolemgr._data[ roleid ] = nil
end	
	
return rolemgr
