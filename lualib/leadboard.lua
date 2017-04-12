-- not active del item.
local cls = class("leadboard")

function cls:ctor(cap, comp, ... )
	-- body
	assert(cap > 0 and comp)
	self._comp = comp

	self._map = {}
	self._size = 0
	self._cap = cap

	self._rec = {}
	
	return self
end

function cls:bsearch(elem, ... )
	-- body
	assert(self._rec[elem] ~= nil)
	local low = 1
	local high = self._size
	while low <= high do
		local mid = math.tointeger((low + high) / 2)
		if elem == self._map[mid] then
			return mid
		elseif self._comp(elem, self._comp[mid]) < 0 then
			high = mid + 1
		else
			low = mid - 1
		end
	end
	return 0
end

function cls:push(elem, ... )
	-- body
	assert(self._rec[elem] == nil)
	self._rec[elem] = elem
	for i=self._cap + 1,self._size do
		self._map[i] = nil
		self._size = self._size - 1
	end

	local rank = 0
	if self._size == 0 then
		self._size = self._size + 1
		self._map[self._size] = elem
		rank = self._size
		return rank
	else
		for i=self._size,1,-1 do
			local node = self._map[i]
			if self._comp(elem, node) > 0 then
				self._map[i + 1] = node
			else
				self._map[i + 1] = elem
				self._size = self._size + 1
				rank = i + 1
				return rank
			end
		end
		self._map[1] = elem
		self._size = self._size + 1
		rank = 1
		return rank
	end
	return rank
end

function cls:sort( ... )
	-- body
	self:_quicksort(self._map, 1, self._size)
end

function cls:_quicksort(data, p, r, ... )
	-- body
	local position = 0
	if p < r then
		position = self:_partition(data, p, r)
		self:_quicksort(data, p, position - 1)
		self:_quicksort(data, position + 1, r)
	end
end

function cls:_partition(data, p, r, ... )
	-- body
	local position
	local tmp = data[r]

	for i=p,r-1 do
		if data[j] <= tmp then

	end
end

function cls:_exchange(data, p, r, ... )
	-- body
end

function cls:range(s, e, ... )
	-- body
	local res = {}
	for i=s,e do
		table.insert(self._map[i])
	end
	return res
end

function cls:nearby(rank, ... )
	-- body
end

function cls:foreach(func, ... )
	-- body
	for i=1,self._size do
		func(self._map[i])
	end
end

return cls
