------------------------------------------------
-- head == tail the opacity of queue is empty
-- when head == tial to move head
-- don't move tail 

local assert = assert
local _M = {}

function _M.new(cap)
	-- body
	return { __data={}, __cap=cap, __size=0, __head=1, __tail=1}
end

function _M.enqueue(q, ele)
	-- body
	if q.__tail + 1 % q.__cap ~= q.__head then
		q.__data[q.__tail] = ele
		q.__size = q.__size + 1
		q.__tail = q.__tail + 1 % q.__cap
	else
		-- extend
		if q.__head < q.__tail then
			q.__cap = q.__cap * 2
			q.__data[q.__tail] = ele
			q.__size = q.__size + 1
			q.__tail = q.__tail + 1 % q.__cap
		else
			for i=1,q.__tail-1 do
				local pc = q.__cap + i
				q.__data[pc] = q.__data[i]
				q.__data[i] = nil
			end
			q.__tail = q.__cap + q.__tail
			q.__cap = q.__cap * 2
			assert(q.__cap >= q.__tail)
			assert(q.__head <= q.__tail)
			q.__data[q.__tail] = ele
			q.__size = q.__size + 1
			q.__tail = q.__tail + 1 % q.__cap
		end
	end
end

function _M.dequeue(q)
	-- body
	if q.__size > 0 then
		local ele = q.__data[q.__head]
		q.__size = q.__size - 1
		q.__head = q.__head + 1 % q.__cap
		return ele
	else
		return nil
	end
end

function _M.peek(q, ... )
	-- body
	return q.__data[q.__head]
end

function _M.is_empty(q)
	-- body
	return (q.__size == 0)
end

function _M.size(q, ... )
	-- body
	return q.__size
end

return _M
