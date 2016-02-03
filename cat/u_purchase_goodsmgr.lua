local u_purchase_goodsmgr = {}
u_purchase_goodsmgr.__data = {}
u_purchase_goodsmgr.__count = 0

local purchase_goods_record = { id, user_id, goods_id, goods_num, currency_type, currency_num, purchase_time }

function purchase_goods_record.new()
 	-- body
 	local t = {}
 	setmetatable( t, { __index = purchase_goods_record } )
 	return t
end 

function u_purchase_goodsmgr.create( tvals )
	assert(tvals)
	local u = goods.new()
	u.id = assert(tvals["id"])
	u.user_id = tvals["user_id"]
	u.goods_id = tvals["goods_id"]
	u.goods_num = tvals["goods_num"]
	u.currency_type = tvals["currency_type"]
	u.currency_num = tvals["currency_num"]
	u.purchase_time = tvals["purchase_time"]
	return u
end	

function u_purchase_goodsmgr:add( u )
	assert(u)
	self.__data[tostring(u.id)] = u
	self.__count = self.__count + 1
end
	
function u_purchase_goodsmgr:delete(id)
	assert(id)
	self.__data[tostring(id)] = nil
end

function u_purchase_goodsmgr:get(id)
	-- body
	return self.__data[tostring(id)]
end

function u_purchase_goodsmgr:get_by_csv_id(csv_id)
	-- body
	for k,v in pairs(self.__data) do
		if v.csv_id == csv_id then
			return v
		end
	end
end

function u_purchase_goodsmgr:get_count()
	-- body
	return self.__count
end

return u_purchase_goodsmgr