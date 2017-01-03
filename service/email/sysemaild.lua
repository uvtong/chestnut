local skynet = require "skynet"
require "skynet.manager"

local sys = 1

local cmd = {}

function cmd.start( ... )
	-- body
	sys = skynet.call(".UID_MGR", "lua", "sysemaild")
	-- skynet.call(".EMAIL", "lua", "login", sys)
	local mail = {}
	mail.id = 1
	mail.from = sys
	mail.to = 0
	mail.title = "abc"
	mail.content = "cbd"
	mail.date = 0
	-- skynet.send(".EMAIL", "lua", "send", mail)
	return true
end

function cmd.close( ... )
	-- body
	return true
end

function cmd.kill( ... )
	-- body
	skynet.exit()
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function (_, _, command, subcmd, ... )
		-- body
		local f = cmd[command]
		local r = f(subcmd, ...)
		if r ~= nil then
			skynet.retpack(r)
		end
	end)
	skynet.register ".SYSEMAIL"
end)