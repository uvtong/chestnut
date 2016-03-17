-- local dbop = require "dbop"
-- t = { tname = "email" , content = { { id = 1} , { isread = 1 } } , condition = 
-- string.format( " uid = %d and id = %d " , 2 , 1 )}
-- local sql = string.format(dbop.tupdate(t))
-- print(sql)

-- if string.match("<input>a</input>", "<%s*(%S+)(%s[^>]*)?>[%s%S]*<%s*%/%1%s*>") then
-- 	print("ture")
-- else
-- 	print("false")
-- end
-- function stripfilename( path )
-- 	-- body
-- 	-- return string.gsub(path, "(.+)/[^/]*%.(jpg|png|css|js)$", "%2")
-- 	--return string.match(path, "(.+)/[^/]*%.html")
-- 	return string.gsub(path, "(.+)/[^/]+%.(%w+)", "%2")
-- end
-- local x = stripfilename("/aba/ac.js")
-- if x then
-- 	print(x, "ture")
-- else
-- 	print("false")
-- end

-- local d = os.date("*t")
-- for k,v in pairs(d) do
-- 	print(k,v)
-- end
-- local t = {year}

-- package.path = ""

-- 123456

local Q = require "lualib/queue"
local que = Q.new(32)



local co_push = coroutine.create (function ()
	-- body
	while true do
		if Q.enqueue(que, "hello") then
			print "ture"
		else
			print "false"
		end
		coroutine.yield(500)
	end
end)

local co_pop = coroutine.create(function ()
	-- body
	while true do
		local r = Q.dequeue(que)
		if r then
			print(r)
		else
			print(r)
		end
		coroutine.yield(500)
	end
end)

local co = coroutine.create(function ()
	-- body
	local last = 0
	while true do
		local now = os.time()
		if now - last > 1 then
			print("abc")
			last = now
			if math.random(1, 2) == 1 then
				coroutine.resume(co_push)
			else
				coroutine.resume(co_pop)
			end
		end
	end
end)

local moniter = coroutine.create(function ()
	-- body
	local last = 0
	while true do
		local now = os.time()
		if now - last > 0.5 then
			last = now
			print("********************8", que.__size, que.__head, que.__tail)
		end
	end
end)

coroutine.resume(co_push)
coroutine.resume(co_pop)
coroutine.resume(co)
coroutine.resume(moniter)
