package.cpath = "../luaclib/?.so;" .. package.cpath
local queue = require "queue"
local q = queue()

local r

local last = os.time()

for i=1,1000000 do
	local item = {}
	item.name = string.format("%d", i)
	if i == 5 then
		r = item
	end
	q:enqueue(item)
end

for i=1,1000000 do
	local item = q:dequeue()
	if item then
		print(item.name)
	end
end

print(os.time() - last)

print(q:size())

-- print(q:del(r))

-- for i=1,8 do
-- 	local item = q:dequeue()
-- 	if item then
-- 		print(item.name)
-- 	end
-- end

-- print(q:size())

-- q:test()