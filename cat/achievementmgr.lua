local achievementmgr = {}
achievementmgr._data = {}

local achievement = { id, type, level, gold, level, combat, gold, exp, raffle, csv_id, kungfu }

function achievement.new( ... )
 	-- body
 	local r = {}
 	setmetatable( r, { __index = achievement } )
 	return r
end 

function achievementmgr.create( t )
	-- body
	local r = achievement.new()
	r.id = assert(t.id)
 	r.user_id = assert(t.user_id)
 	r.finished = assert(t.finished)
 	r.csv_id = assert(t.csv_id)
 	r.type = assert(t.type)
 	r.level = t.level
 	r.exp = t.exp
 	r.raffle = t.raffle
 	r.kungfu = t.kungfu
 	r.combat = t.combat
 	r.gold = t.gold
 	r.r_gold = t.r_gold
	return r
end

function achievementmgr:delete( id )
	if nil ~= self._data[tostring(id)] then
		table.remove(self._data, id)
		-- TODO   delete user data and relative roles data in database
	end
end

function achievementmgr:find( id )
	local uid = tostring( id )
	return self._data[uid]
end

function achievementmgr:get( id )
	-- body
	return self._data[tostring(id)]
end

function achievementmgr:get_by_type( type )
	-- body
	local r = {}
	local idx = 1
	for k,v in ipairs(self._data) do
		if v.type == type and v.finished < 100 then
			r[i] = v
		end
	end
	return r
end

function achievementmgr:add( u )
	assert(u)
	self._data[string.format("%d", u.id)] = u
end

return achievementmgr