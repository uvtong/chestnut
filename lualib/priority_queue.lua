------------------------------------------------
-- head == tail the opacity of queue is empty
-- when head == tial to move head
-- don't move tail 
local log = require "log"
local assert = assert
local _M = {}

function _M.new(sz, compare)
	-- body
	assert(sz and compare)
	assert(type(compare) == "function")
	return { __data={}, __cap=sz, __size=0, __head=1, __tail=1, __compare=compare, __ele_pg={}}
end

function _M.backward(q, ele, ... )
	-- body
	assert(false)
	if q.__size <= 1 then
		return 
	else
		local pg = q.__ele_pg[ele]
		if pg then
			local idx = pg.idx
			idx = (idx - 1) > 0 and (idx - 1) or q.__cap
			local prior = 1
		else
			log.print_error("ele must is a ")
		end
	end
end

function _M.forward(q, ele, ... )
	-- body
	assert(false)
end

function _M._insert(q, ele, ... )
	-- body
	assert(q.__tail + 1 % q.__cap ~= q.__head)
	local idx = q.__tail - 1 and q.__tail - 1 or q.__cap
	while idx ~= q.__head do
		if q.__compare(ele, q.__head[idx].ele) then
			q.__data[idx + 1 % q.__cap] =  q.__data[idx]
		else
			q.__data[idx + 1 % q.__cap] = { ele=ele, idx=idx+1%q.__cap }
			q.__size = q.__size + 1
			q.__tail = q.__tail + 1 % q.__cap		
			break
		end
	end
end

function _M.enqueue(q, ele)
	-- body
	if q.__tail + 1 % q.__cap ~= q.__head then
		_M._insert(q, ele)
	else
		-- extend
		if q.__head < q.__tail then
			q.__cap = q.__cap * 2
			_M._insert(q, ele)
		else
			for i=1,q.__tail do
				local pc = q.__cap + i
				q.__data[pc] = q.__data[i]
				q.__data[i] = nil
			end
			q.__tail = q.__cap + q.__tail
			q.__cap = q.__cap * 2
			assert(q.__cap >= q.__tail)
			assert(q.__head <= q.__tail)
			_M._insert(q, ele)
		end
	end
end

function _M.dequeue(q)
	-- body
	if q.__size > 0 then
		local ele = q.__data[q.__head]
		q.__size = q.__size - 1
		q.__head = q.__head - 1 % q.__cap
		return ele
	else
		return nil
	end
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
