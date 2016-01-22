local dbop = require "dbop"
t = { tname = "email" , content = { { id = 1} , { isread = 1 } } , condition = 
 string.format( " uid = %d and id = %d " , 2 , 1 )}
local sql = string.format(dbop.tupdate(t))
print(sql)