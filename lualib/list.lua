local assert = assert
local _M = {}

function _M.new( ... )
	-- body
	local node = {}
	node.size = 0
	node.next = nil
	return node
end

function _M.add(head, data, ... )
	-- body
	assert(head and data)
	head.size = head.size + 1
	local node = head
	while node.next do
		node = node.next
	end
	local n = {}
	n.data = data
	n.next = nil
	node.next = n
	return n
end

function _M.del(head, data, ... )
	-- body
	assert(head and data)
	local pri = head
	local node = head.next
	while node do
		if node.data == data then
			head.size = head.size - 1
			pri.next = node.next
			break
		end
		pri = node
		node = node.next
	end
end

function _M.pop(head, ... )
	-- body
	if head.size > 0 then
		local node = head.next
		head.next = node.next
		head.size = head.size - 1
		return node
	else
	end
end

function _M.foreach(head, func, ... )
	-- body
	assert(head)
	local node = head.next
	while node do
		node = node.next
		if func then
			func(node.data)
		end
	end
end

return _M