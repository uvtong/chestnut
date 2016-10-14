local assert = assert
local _M = {}

function _M.new(data, ... )
	-- body
	local node = {}
	node.data = data
	node.next = nil
	return node
end

function _M.add(head, data, ... )
	-- body
	assert(head and data)
	local node = head
	while node.next do
		node = node.next
	end
	-- node.next == nil
	assert(node.next == nil)
	local n = _M.new(data)
	node.next = n
	return n
end

function _M.del(head, data, ... )
	-- body
	local pri = head
	local node = head.next
	while node do
		if node.data == data then
			pri.next = node.next
			break
		end
		pri = node
		node = node.next
	end
end

return _M