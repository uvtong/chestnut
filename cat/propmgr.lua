local propmgr = {}
propmgr._data = {}

local prop = { id , user_id , num, csv_id, level, combat, skill, type }

function prop.new( ... )
 	-- body
 	local r = {}
 	setmetatable( r, { __index = prop } )
 	return r
end 

function propmgr.create( t )
	-- body
	local r = prop.new()
	r.id = assert(t.id)
	r.user_id = assert(t.user_id)
	r.num = assert(t.num)
	r.csv_id = assert(t.csv_id)
	r.level = t.level
	r.combat = t.combat
	r.skill = t.skill
	r.type = t.type
	return r
end
	
function propmgr:delete( id )
	if nil ~= self._data[tostring(id)] then
		table.remove(self._data, id)
		-- TODO   delete user data and relative roles data in database
	end
end

function propmgr:get( id )
	local uid = tostring( id )
	return self._data[uid]
end

function propmgr:get_by_csvid( csv_id )
	-- body
	for k,v in pairs(self._data) do
		if v.csv_id == csv_id then
			return v
		end
	end
end

function propmgr:get_by_type( type )
	-- body
	local r = {}
	local idx = 1
	for i,v in ipairs(self._data) do
		if type == v.type then
			r[idx] = v
			idx = idx + 1
		end
	end
	return r
end

function propmgr:add( u )
	assert(u)
	self._data[string.format("%d", u.id)] = u
end

return propmgr
