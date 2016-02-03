local _M = {}
_M.__data = {}
_M.__count = 0

local _Meta = { csv_id, name, diamond, first, gift, rmb, recharge_before, recharge_after, goods_id, icon_id}

function _Meta.new()
 	-- body
 	local t = {}
 	setmetatable( t, { __index = _Meta } )
 	return t
end 

function _M.create( P )
	assert(P)
	local u = _Meta.new()
	u.csv_id = P["csv_id"]
	u.name = P.name
	u.diamond = P.diamond
	u.first = P.first
	u.gift = P.gift
	u.rmb = P.rmb
	u.recharge_before = P.recharge_before
	u.recharge_after = P.recharge_after
	u.goods_id = P.goods_id
	u.icon_id = P.icon_id
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
