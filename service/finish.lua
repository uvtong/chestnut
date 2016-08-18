local skynet = require "skynet"
require "skynet.manager"
local error = skynet.error

local CMD = {}

function CMD.exit(source)
	-- body
	-- skynet.exit()
	skynet.error("process will be finished.")
	skynet.newservice("abort")
end

skynet.start( function () 
	skynet.dispatch("lua" , function( _, source, command, ... )
		local f = assert(CMD[command])
		local r = f(source, ...)
		if r then
			skynet.ret(skynet.pack(r))
		end
	end)
	skynet.register ".FINISH"
	skynet.send(".CODWEB", "lua", "finish")
end)