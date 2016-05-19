local skynet = require "skynet"

local id = 1

local CMD = {}


skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(_, source, command, ...)
		print("agent is called" , command)
		local f = CMD[command]
		local result = f(source, ... )
		if result then
			skynet.ret(skynet.pack(result))
		end
	end)
	id = skynet.call(".scene", "lua", "register", skynet.self())
end)