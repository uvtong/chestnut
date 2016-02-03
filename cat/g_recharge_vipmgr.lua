local _M = {}
_M.__data = {}
_M.__count = 0

local _Meta = { id, vip, diamond, gold_gift, exp_gift, gold_top, enhance_s_rate, a, s_diamond, c_diamond, shop_refresh_count}

function _Meta.new()
 	-- body
 	local t = {}
 	setmetatable( t, { __index = _Meta } )
 	return t
end 

function _M.create( P )
	assert(P)
	local u = _Meta.new()
	u.id = assert(P["id"])
	u.vip = P.vip
	u.diamond = P.diamond
	u.gold_gift = P.gold_gift
	u.exp_gift = P.exp_gift
	u.gold_top = P.gold_top
	u.enhance_s_rate = P.enhance_s_rate
	u.a = P.a
	u.s_diamond = P.s_diamond
	u.c_diamond = P.c_diamond
	u.shop_refresh_count = P.shop_refresh_count
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

function _M:get_by_vip(vip)
	-- body
	for k,v in pairs(self.__data) do
		if v.vip == vip then
			return v
		end
	end
end

function _M:get_count()
	-- body
	return self.__count
end

return _M
