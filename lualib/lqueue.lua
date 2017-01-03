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
	q.__size = q.__size + 1
	if q.__size >= q.__cap then
		if q.__head < q.__tail then
		else
			for i=1,q.__tail-1 do
				local pc = q.__cap + i
				q.__data[pc] = q.__data[i]
				-- q.__data[i] = nil
			end
			q.__tail = q.__cap + q.__tail
		end
		q.__cap = q.__cap * 2
	end
	q.__data[q.__tail] = ele
	if q.__tail + 1 > q.__cap then
		q.__tail = 1
	else
		q.__tail = q.__tail + 1
	end
end

function _M.dequeue(q)
	-- body
	if q.__size > 0 then
		local ele = q.__data[q.__head]
		q.__size = q.__size - 1
		if q.__head + 1 > q.__cap then
			q.__head = 1
		else
			q.__head = q.__head + 1
		end
		return ele
	else
		return nil
	end
end

function _M.peek(q, ... )
	-- body
	return q.__data[q.__head]
end

function _M.size(q, ... )
	-- body
	return q.__size
end

function _M.foreach(q, func, ... )
	-- body
	local i = q.__head
	while i ~= q.__tail do
		func(q.__data[i])
		i = i + 1 <= q.__cap and i + 1 or 1
	end
end

return _M
