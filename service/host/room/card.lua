local cls = class("card")

function cls:ctor(v, ... )
	-- body
	self._type = v >> 4 & 0x0f
	self._num = v & 0x0f
	self._value = v
	return self
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

function cls.mt(c1, c2, ... )
	-- body
	if c1.get_type() == 5 then
		return true
	elseif c1.get_type() == 4 then
		if c2.get_type() == 5 then
			return false
		else
			return true
		end
	elseif c1.get_num() == 2 then
		if c2.get_type() == 4 or c2.get_type() == 5 then
			return false
		elseif c1 == c2 then
			if c1.get_type() > c2.get_type() then
				return true
			else
				return false
			end
		else
			return true
		end
	elseif c1.get_num() == 1 then
		if c2.get_type() == 5 or c2.get_type() == 4 or c2.get_num() == 2 then
			return false
		elseif c2.get_num() == 1 then
			if c1.get_type() > c2.get_type() then
				return true
			else
				return false
			end
		else
			return true
		end
	elseif c1.get_num() > c2.get_num() then
		return true 
	elseif c1.get_num() == c2.get_num() then
		if c1.get_type() > c2.get_type() then
			return true
		else
			return false
		end
	end
end

function cls:lt(c, ... )
	-- body
	return not self:mt(c)
end
return cls