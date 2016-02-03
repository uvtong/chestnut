local _M = {}
_M.__data = {}
_M.__count = 0

local _Meta = { id, user_id, finished, csv_id, name, sub_type, param1, param2, prop_pic, intro, level, icon_id}

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
	u.csv_id = P["csv_id"]
	u.name = P["name"]
	u.sub_type = P["sub_type"]
	u.param1 = P["param1"]
	u.param2 = P["param2"]
	u.prop_pic = P["prop_pic"]
	u.intro = P["intro"]
	u.level = P["level"]
	u.icon_id = P["icon_id"]
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
