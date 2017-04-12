local skynet = require "skynet"
require "skynet.manager"

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

function CMD.login(uid, agent, ... )
	-- body
	local u = {
		uid = uid,
		agent = agent,
	}
	users[uid] = u
end

function CMD.afx(uid, ... )
	-- body
	if users[uid] then
		users[uid] = nil
	end
end

function CMD.say(from, to, word)
	if users[to] then
		skynet.send(users[to].agent, "lua", "say", from, word)
	end
end

skynet.start(function () 
	skynet.dispatch( "lua" , function( _, _, cmd, subcmd, ... )
		local f = CMD[cmd]
		if f then
			local r = f(subcmd, ...)
			if r ~= nil then
				skynet.retpack(r)
			end
		end
	end)
	skynet.register ".CHAT"
end)