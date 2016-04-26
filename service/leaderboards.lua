local skynet = require "skynet"

local CMD = {}

function CMD.abc()
	-- body
end

skynet.start(function ()
	-- body
	skynet.dispatch("lua", function(_,_, command, subcmd, ...)
		if command ~= "abc" then
			local f = CMD[command]
			local r = f( ... )
			if r then
				skynet.ret(skynet.pack(r))
			end
		else
		end
	end)
end)