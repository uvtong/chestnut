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
function stripfilename( path )
	-- body
	-- return string.gsub(path, "(.+)/[^/]*%.(jpg|png|css|js)$", "%2")
	--return string.match(path, "(.+)/[^/]*%.html")
	return string.gsub(path, "(.+)/[^/]+%.(%w+)", "%2")
end
local x = stripfilename("/aba/ac.js")
if x then
	print(x, "ture")
else
	print("false")
end