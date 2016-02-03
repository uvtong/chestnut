local g_refresh_costmgr = {}
g_refresh_costmgr.__data = {}
g_refresh_costmgr.__count = 0

local g_refresh_cost = { id, csv_id, cost}

function g_refresh_cost.new( ... )
 	-- body
 	local t = {}
 	setmetatable( t, { __index = g_refresh_cost } )
 	return t
end 

function g_refresh_costmgr.create( tvals )
	assert(tvals)
	local u = g_refresh_cost.new()
	u.id = assert(tvals["id"])
	u.csv_id = tvals["csv_id"]
	u.cost = tvals["cost"]
	return u
end	

function g_refresh_costmgr:add( u )
	assert(u)
	self.__data[tostring(u.id)] = u
	self.__count = self.__count + 1
end
	
function g_refresh_costmgr:delete(id)
	assert(id)
	self.__data[tostring(id)] = nil
end

function g_refresh_costmgr:get(id)
	-- body
	return self.__data[tostring(id)]
end

function g_refresh_costmgr:get_by_csv_id(csv_id)
	-- body
	for k,v in pairs(self.__data) do
		if v.csv_id == csv_id then
			return v
		end
	end
end

function g_refresh_costmgr:get_count()
	-- body
	return self.__count
end

return g_refresh_costmgr