local skynet = require "skynet"

local CMD = {}

function CMD:test( ... )
	-- body
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function (_, _, cmd, ... )
		-- body
		local f = assert(CMD[cmd])
		local r = f(...)
		skynet.retpack(r)
	end)
end)