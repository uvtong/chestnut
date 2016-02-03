local _M = {}
_M.__data = {}
_M.__count = 0

local _Meta = { id, user_id, distribute_dt, prop_id, prop_csv_id, prop_num, c_type, collected}

function _Meta.new()
 	-- body
 	local t = {}
 	setmetatable( t, { __index = _Meta } )
 	return t
end 

function _M.create( tvals )
	assert(tvals)
	local u = _Meta.new()
	u.id = assert(tvals["id"])
	u.user_id = tvals.user_id
	u.distribute_dt = tvals.distribute_dt
	u.prop_id = tvals.prop_id
	u.prop_csv_id = tvals.prop_csv_id
	u.prop_num = tvals.prop_num
	u.c_type = tvals.c_type
	u.icon_id = tvals.icon_id
	u.collected = tvals.collected
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

function _M:get_by_csv_id(csv_id)
	-- body
	for k,v in pairs(self.__data) do
		if v.csv_id == csv_id then
			return v
		end
	end
end

function _M:get_count()
	-- body
	return self.__count
end

return _M