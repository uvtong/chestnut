local skynet = require "skynet"

local sys = 1

local cmd = {}

function cmd.start( ... )
	-- body
	skynet.call(".EMAIL", "lua", "login", sys)
	local mail = {}
	mail.id = 1
	mail.from = sys
	mail.to = 0
	mail.title = "abc"
	mail.content = "cbd"
	mail.date = 0
	skynet.send(".EMAIL", "lua", "send", mail)
	return true
end

function cmd.kill( ... )
	-- body
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function (_, _, cmd, subcmd, ... )
		-- body
		local f = CMD[cmd]
		local r = f(subcmd, ...)
		if r ~= nil then
			skynet.retpack(r)
		end
	end)
	skynet.register ".SYSEMAIL"
end)