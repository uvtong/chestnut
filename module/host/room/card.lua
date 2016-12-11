local assert = assert
local cls = class("card")

function cls:ctor(v, ... )
	-- body
	assert(v)
	self._value = v
	local t = v >> 4 & 0x0f
	local num = v & 0x0f
	self._type = t
	self._num =  num
	self._idx = 0
	self._master = false  -- 判断是否已经被分配
	self._bright = false  -- 判断是否已经被选中

	return self
end

function cls:tof( ... )
	-- body
	return self._type
end

function cls:nof( ... )
	-- body
	return self._num
end

function cls:get_type( ... )
	-- body
	return self._type
end

function cls:get_num( ... )
	-- body
	return self._num
end

function cls:get_value( ... )
	-- body
	return self._value
end

-- position
function cls:get_idx( ... )
	-- body
	return self._idx
end

function cls:set_idx(idx, ... )
	-- body
	self._idx = idx
end

function cls:set_master(m, ... )
	-- body
	self._master = m
end

function cls:get_master( ... )
	-- body
	return self._master
end

-- 比较单牌,这里只比较数字
function cls:mt(o, ... )
	-- body
	local t1 = self._type
	local n1 = self._num
	local t2 = o._type
	local n2 = o._num
	if t1 == 5 then
		return true
	elseif t2 == 5 then
		return false
	elseif t1 == 4 then
		if t2 == 5 then
			return false
		else
			return true
		end
	elseif t2 == 4 then
		if t1 == 5 then
			return true
		else
			return false
		end
	elseif n1 > 0 and n2 > 0 then
		if n1 == n2 then
			return false
		elseif n1 == 2 and n2 ~= 2 then
			return true
		elseif n2 == 2 and n1 ~= 2 then
			return false
		elseif n1 == 1 then
			if n2 == 2 or n2 == 1 then
				return false
			else
				return true
			end
		elseif n2 == 1 then
			if n1 == 2 then
				return true
			else
				return false
			end
		else
			return n1 > n2
		end
	else
		assert(false)
		return false
	end
end

function cls:eq(o, ... )
	-- body
	local t1 = self._type
	local n1 = self._num
	local t2 = o._type
	local n2 = o._num
	if n1 > 0 and n2 > 0 then
		return (n1 == n2)
	else
		return false
	end
end

function cls:lt(o, ... )
	-- body
	if not self:mt(o) or not self:eq(o) then
		return true
	else
		return false
	end
end

-- 发牌的时候的比较，这里既比较数字也比较类型
function cls:mt_t(o, ... )
	-- body
	assert(o)
	if self._type == 5 then
		return true
	elseif self._type == 4 then
		if o._type == 5 then
			return false
		else
			return true
		end
	elseif self._num == o._num then -- 两个数字相同的时候，判断type
		if self._type > o._type then
			return true
		else
			return false
		end
	elseif self._num == 2 then
		return true
	elseif o._num == 2 then
		return false
	elseif self._num == 1 then
		if o._num == 2 then
			return false
		else
			return true
		end
	elseif o._num == 1 then
		if self._num == 2 then
			return true
		else
			return false
		end
	elseif self._num > o._num then
		return true
	else
		return false
	end
end

function cls:eq_t(o, ... )
	-- body
	return false
end

function cls:lt_t(o, ... )
	-- body
	return not self:mt_t(o) and not self:lt_t(o)
end

function cls:set_bright(flag, ... )
	-- body
	self._bright = flag
end

function cls:get_bright( ... )
	-- body
	return self._bright
end

function cls:clear( ... )
	-- body
	self._idx = 0         -- deal 
	self._master = false  -- deal
	self._bright = false  -- selection
end

return cls