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
	local sql = string.format("update logintimes set times = %d where uid = %d", t[uid], uid)
	query.update("logintimes", sql, query.DB_PRIORITY_3)
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
end)