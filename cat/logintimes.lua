package.path = "./../lualib/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"
local query = require "query"

local t = {}

local CMD = {}

function CMD.login(uid)
	-- body
	if t[uid] == nil then
		t[uid] = 0
	end
	t[uid] = t[uid] + 1
	if t[uid] == 1 then
		local sql = string.format("insert into logintimes (uid, times) values (%d, %d)", uid, t[uid])
		print(sql)
		query.insert_sql("logintimes", sql, query.DB_PRIORITY_1)
	else	
		local sql = string.format("update logintimes set times = %d where uid = %d", t[uid], uid)
		print(sql)
		query.update_sql("logintimes", sql, query.DB_PRIORITY_1)
	end
	return t[uid]
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(_, source, command, ...)
		local f = CMD[command]
		local result = f(source, ... )
		if result then
			skynet.ret(skynet.pack(result))
		end
		end)
	local sql = string.format("select * from logintimes")
	local res = query.select_sql_wait("logintimes", sql, query.DB_PRIORITY_3)
	for i,v in ipairs(res) do
		t[v.uid] = v.times
	end
end)