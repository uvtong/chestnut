package.path = "../../module/host/lualib/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"

local CMD = {}

function CMD.start( ... )
	-- body
	return true
end

function CMD.close( ... )
	-- body
	return true
end

function CMD.kill( ... )
	-- body
	skynet.exit()
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		print("called", command)
		local f = CMD[command]
		local result = f(...)
		if result then
			skynet.ret(skynet.pack(result))
		end
	end)
	-- skynet.fork(update_db)
	skynet.register ".game"
end)
