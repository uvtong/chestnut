local skynet = require "skynet"
require "skynet.manager"

local sys = 1 -- sys == 1
local users = {}

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
end

function CMD.login(uid, ... )
	-- body
	local u = users[uid]
	if u then
		if u.outbox then
		else
			u.outbox = {}
		end
	else
		u = {
			outbox = {}
		}
		users[uid] = u
	end
	return true
end

function CMD.send(from, to, mail, ... )
	-- body
	local u = users[from]
	table.insert(u.outbox, mail)
end

function CMD.recv(to, ... )
	-- body
	local u = users[sys]
	if #u.outbox > 0 then
	end
end

function CMD.recv( ... )
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
	skynet.register ".EMAIL"
end)