------------------------------------------------
-- head == tail the opacity of queue is empty
-- make head == tial move head
-- don't move tail 

local Queue = {}

function Queue.new(sz)
	-- body
	return { __data={}, __size=sz, __head=1, __tail=1}
end

function Queue.enqueue(Q, E)
	-- body
	if Q.__tail + 1 ~= Q.__head then
		if Q.__tail + 1 > Q.__size then
			if Q.__head == 1 then
				Q.__size = Q.__size * 2
				Q.__data[Q.__tail] = E
				Q.__tail = Q.__tail + 1
				return true
			else
				Q.__data[Q.__tail] = E
				Q.__tail = 1
				return true
			end
		else
			Q.__data[Q.__tail] = E
			Q.__tail = Q.__tail + 1
			return true
		end
	else
		assert(false)
		return false
	end
end

function Queue.dequeue(Q)
	-- body
	if Q.__head ~= Q.__tail then
		if Q.__head < Q.__tail then
			local r = Q.__data[Q.__head]
			Q.__head = Q.__head + 1
			return r
		elseif Q.__head > Q.__tail then
			if Q.__head + 1 > Q.__size then
				local r = Q.__data[Q.__head]
				Q.__head = 1
				return r
			else
				local r = Q.__data[Q.__head]
				Q.__head = Q.__head + 1
				return r
			end
		else
			assert(false)
		end
	else
		return nil
	end
end

return Queue