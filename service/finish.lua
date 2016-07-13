local skynet = require "skynet"

local CMD = {}

function CMD.exit(source)
	-- body
	print("all service has been finished.")
	-- skynet.exit()
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
	skynet.send(".CODWEB", "lua", "finish")
end)