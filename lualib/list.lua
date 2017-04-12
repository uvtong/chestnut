local assert = assert
local _M = {}

function _M.new( ... )
	-- body
	local node = {}
	node.size = 0
	node.head = nil
	node.tail = nil
	return node
end

function _M.insert_head(L, ele, ... )
	-- body
	local node = {}
	node.data = ele
	node.next = L.head
	L.head = node
	if L.size == 0 then
		L.tail = node
	end
	L.size = L.size + 1
end

function _M.insert_tail(L, ele, ... )
	-- body
	local node = {}
	node.data = ele
	if L.size == 0 then
		node.next = L.tail
		L.tail = node
		L.head = node
	else
		node.next = L.tail.next
		L.tail.next = node
		L.tail = node
	end
	L.size = L.size + 1
end

function _M.remove(L, ele, ... )
	-- body
	assert(L and ele)
	if L.size == 0 then
		return false
	elseif L.size == 1 then
		if L.head.data == ele then
			L.head = nil
			L.tail = nil
			L.size = L.size - 1
			return true
		else
			return false
		end
	else
		if L.head.data == ele then
			L.head = L.head.next
			L.size = L.size - 1
			return true
		else
			local pred = L.head
			local node = L.head.next
			while node do
				if node.data == ele then
					pred.next = node.next
					head.size = head.size - 1
					return true
				end
				pred = node
				node = node.next
			end
			return false
		end
	end
end

function _M.remove_head(L, ... )
	-- body
	assert(L)
	if L.size == 0 then
		return false
	elseif L.size == 1 then
		L.head = nil
		L.tail = nil
		L.size = L.size - 1
		return true
	elseif L.size > 1 then
		L.head = L.head.next
		L.size = L.size - 1
		return true
	end
	return false
end

function _M.remove_tail(L, ... )
	-- body
	assert(L)
	if L.size == 0 then
		return false
	elseif L.size == 1 then
		L.head = nil
		L.tail = nil
		L.size = L.size - 1
	elseif L.size > 1 then
		local node = L.head
		while node do
			if node.next == L.tail then
				break
			end
			node = node.next
		end
		assert(node)
		L.tail = node
		L.size = L.size - 1
		return true
	end
	return false
end

function _M.head(L, ... )
	-- body
	return L.head.data
end

function _M.tail(L, ... )
	-- body
	return L.tail.data
end

-- depreated
function _M.pop(L, ... )
	-- body
	local ele = _M.head(L)
	_M.remove_head(L)
	return ele
end

function _M.foreach(L, func, ... )
	-- body
	assert(L)
	local node = L.head
	while node do
		if func then
			func(node.data)
		end
		node = node.next
	end
end

function _M.sort(L, comp, ... )
	-- body
	assert(L and comp)	
end

function _M.size(L, ... )
	-- body
	return L.size
end

return _M