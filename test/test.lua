package.cpath = "../luaclib/?.so;" .. package.cpath
package.path = "../lualib/?.lua;" .. package.path

-- local math3d = require "math3d"

-- local aabb1 = math3d.aabb(math3d.vector3(0, 0, 0), math3d.vector3(3, 3, 3))
-- local aabb2 = math3d.aabb(math3d.vector3(1, 1, 1), math3d.vector3(4, 4, 4))

-- local center = math3d.vector3(0, 0, 0)
-- aabb1:getCenter(center)
-- local x, y, z = center:unpack()
-- print(x, y, z)

-- local corners = {}
-- for i=1,8 do
-- 	table.insert(corners, math3d.vector3(0, 0, 0))
-- end
-- aabb1:getCorners(corners)

-- for i,v in ipairs(corners) do
-- 	local x, y, z = v:unpack()
-- 	print(x, y, z)
-- end

-- if aabb1:intersects(aabb2) then
-- 	print("ok")
-- else
-- 	print(false)
-- end

local queue = require "lqueue"

local q = queue.new(3)

for i=1,11 do
	queue.enqueue(q, i)
end

-- print(queue.size(q))

for i=1,5 do
	print(queue.dequeue(q))
end

for i=1,20 do
	queue.enqueue(q, i * 10)
end

for i=1,8 do
	print(queue.dequeue(q))
end

print(queue.size(q))
print(q.__cap)

local sz = queue.size(q)
for i=1,sz do
	print(queue.dequeue(q))
end


-- local q = queue()

-- local r

-- local last = os.time()

-- for i=1,10 do
-- 	local item = {}
-- 	item.name = string.format("%d", i)
-- 	if i == 5 then
-- 		r = item
-- 	end
-- 	q:enqueue(item)
-- end

-- print(q:del(r))

-- print(q:size())

-- for i=1,10 do
-- 	local item = q:dequeue()
-- 	if item then
-- 		print(item.name)
-- 	end
-- end

-- print(q:size())

-- for i=1,6 do
-- 	local item = {}
-- 	item.name = string.format("%d", i * 10)
-- 	if i == 5 then
-- 		r = item
-- 	end
-- 	q:enqueue(item)
-- end

-- for i=1,11 do
-- 	local item = q:dequeue()
-- 	if item then
-- 		print(item.name)
-- 	end
-- end

-- print(os.time() - last)



-- print(q:del(r))

-- for i=1,8 do
-- 	local item = q:dequeue()
-- 	if item then
-- 		print(item.name)
-- 	end
-- end

-- print(q:size())

-- q:test()
