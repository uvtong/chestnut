local cls = class("leadboard")

function cls:ctor(cap, ... )
	-- body
	self._head = nil
	self._tail = nil
	self._size = 0
	self._cap = cap
	self._map = {}
	return self
end

function cls:push_back(ele, comp, ... )
	-- body
	local nnode
	if self._map[ele] then
		nnode = self._map[ele]
		if self._head == nnode then
		else
			local node = nnode.pred
			
	else
		nnode.data = ele
		nnode.next = nil
		nnode.pred = nil
		if self._size == 0 then
			self._head = nnode
			self._tail = nnode
			self._size = self._size + 1
		elseif self._size == 1 then
			if self._cap > self._size then
				local node = self._tail
				if comp(node.ele, ele) then
					nnode.pred = node
					node.next = nnode
					self._size = self._size + 1
				else
					self._head = nnode
					nnode.next = node
					node.pred = nnode
					self._size = self._size + 1
				end
			end
		elseif self._size > 1 then
			local nnode = {}
			nnode.data = ele
			nnode.next = nil
			nnode.pred = nil
			if self._cap > self._size then
				local node = self._tail
				while node do
					if comp(node.ele, ele) then
						nnode.next = node.next
						nnode.pred = node
						node.next = nnode
						if node == self._tail then
							self._tail = nnode
						end
						self._size = self._size + 1
					else
						node = node.pred
					end
				end
			else
				local node = self._tail
				while node do
					if comp(node.ele, ele) then
						nnode.next = node.next
						nnode.pred = node
						node.next = nnode
						if node == self._tail then
							self._tail = nnode
						end
						self._tail = self._tail.pred
						-- self._size = self._size + 1
					else
						node = node.pred
					end
				end
			end
		end
	end
	
end


function cls:foreach(func, ... )
	-- body
	local node = self._head
	while node then
		node = node.next
		func(node.data)
	end
end

return cls
