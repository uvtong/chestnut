local equipmentmgr = {}
equipmentmgr.__data = {}
equipmentmgr.__count = 0

local goods = { id, csv_id, type, currency_type, gold, diamond, rmb, prop_csv_id, prop_num, c_startingtime, c_countdown, c_a_num, c_u_num}

function goods.new( ... )
 	-- body
 	local t = {}
 	setmetatable( t, { __index = goods } )
 	return t
end 

function goodsmgr.create( tvals )
	assert(tvals)
	local u = goods.new()
	u.id = assert(tvals["id"])
	u.csv_id = tvals["csv_id"]
	u.num = tvals["num"]
	u.currency_type = assert(tvals["currency_type"])
	u.gold = tvals["gold"]
	u.diamond = tvals["diamond"]
	u.rmb = tvals["rmb"]
	u.prop_csv_id = tvals["prop_csv_id"]
	u.prop_num = tvals["prop_num"]
	u.c_startingtime = assert(tvals["c_startingtime"])
	u.c_countdown = tvals["c_countdown"]
	u.c_a_num = tvals["c_a_num"]
	u.c_u_num = tvals["c_u_num"]
	return u
end	

function goodsmgr:add( u )
	assert(u)
	self.__data[tostring(u.id)] = u
	self.__count = self.__count + 1
end
	
function goodsmgr:delete(id)
	assert(id)
	self.__data[tostring(id)] = nil
end

function goodsmgr:get(id)
	-- body
	return self.__data[tostring(id)]
end

function goodsmgr:get_by_csv_id(csv_id)
	-- body
	for k,v in pairs(self.__data) do
		if v.csv_id == csv_id then
			return v
		end
	end
end

function goodsmgr:get_count()
	-- body
	return self.__count
end

return goodsmgr