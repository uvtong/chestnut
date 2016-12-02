local cls = class("leadboard")

function cls:ctor(cap, ... )
	-- body
	assert(cap)
	self._head = nil
	self._tail = nil
	self._size = 0
	self._cap = cap
	self._map = {}
	return self
end

function cls:push_back(ele, comp, ... )
	-- body
	assert(ele ~= nil and comp)
	local nnode
	if self._map[ele] then
		nnode = self._map[ele]
		if self._head == nnode then
		else
			local node = nnode.pred
			while node do
				if comp(node.data, nnode.data) then
					break
				else
					-- exchange
					local pred = node.pred
					local next = nnode.next
					if pred then
						pred.next = nnode
					end
					nnode.pred = pred

					nnode.next = node
					node.pred = nnode

					node.next = next
					if next then
						next.pred = node
					end
					break
				end
				node = nnode.pred
			end
		end
	else
		print("insert", ele)
		-- insert
		nnode = {}
		nnode.data = ele
		nnode.next = nil
		nnode.pred = nil
		self._map[ele] = nnode
		if self._size == 0 then
			self._head = nnode
			self._tail = nnode
			self._size = self._size + 1
		elseif self._size > 0 then
			local f = false
			local node = self._tail
			while node do
				if comp(node.data, nnode.data) then
					f = true
					nnode.next = node.next
					if node.next then
						node.next.pred = nnode
					end
					nnode.pred = node
					node.next = nnode
					self._size = self._size + 1
					break
				else
					node = node.pred
				end
			end

			if f then
			else
				nnode.next = self._head
				self._head.pred = nnode
				self._head = nnode
				self._size = self._size + 1
			end

			node = self._tail
			while node.next do
				node = node.next
			end
			self._tail = node
			assert(self._tail.next == nil)

			node = self._head
			while node.pred do
				node = node.pred
			end
			self._head = node
			assert(self._head.pred == nil)

			assert(self._cap > 0)
			-- print(self._cap, self._size)
			while self._cap < self._size do
				local node = self._tail.pred
				node.next = nil
				self._tail.pred = nil
				self._tail = node
				self._size = self._size - 1
				self._map[node.data] = nil
			end
		end
	end
end

function cls:foreach(func, ... )
	-- body
	local node = self._head
	while node do
		func(node.data)
		node = node.next
	end
end

return cls
