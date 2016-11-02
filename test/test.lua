package.cpath = "../luaclib/?.so;" .. package.cpath
package.path = "../lualib/?.lua;" .. package.path


-- local x = {1, 2}

-- for k,v in pairs(x) do
-- 	print(k,v)
-- end

local math3d = require "math3d"

local aabb1 = math3d.aabb(math3d.vector3(0, 0, 0), math3d.vector3(3, 3, 3))
-- local aabb2 = math3d.aabb(math3d.vector3(1, 1, 1), math3d.vector3(4, 4, 4))

local identity = math3d.matrix()
identity:trans(2, 2, 2)

identity:unpack()
local m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15, m16 = identity:unpack()
print(m13, m14, m15, m16)

aabb1:transform(identity)

local center = math3d.vector3(0, 0, 0)
aabb1:getCenter(center)
local x, y, z = center:unpack()
print(x, y, z)


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
-- local queue = require "queue"
-- local q = queue()

-- local r

-- local last = os.time()

-- for i=1,1000000 do
-- 	local item = {}
-- 	item.name = string.format("%d", i)
-- 	if i == 5 then
-- 		r = item
-- 	end
-- 	q:enqueue(item)
-- end

-- for i=1,1000000 do
-- 	local item = q:dequeue()
-- 	if item then
-- 		print(item.name)
-- 	end
-- end

-- print(os.time() - last)

-- print(q:size())

-- print(q:del(r))

-- for i=1,8 do
-- 	local item = q:dequeue()
-- 	if item then
-- 		print(item.name)
-- 	end
-- end

-- print(q:size())

-- q:test()