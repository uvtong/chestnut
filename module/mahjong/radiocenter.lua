local skynet = require "skynet"
require "skynet.manager"
local log = require "log"

local users = {}
local toast1 = "weixinhao:nihao"

local cmd = {}

function cmd.start( ... )
	-- body
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

function cmd.login(suid, agent, ... )
	-- body
	users[suid] = agent
end

function cmd.afk(suid, ... )
	-- body
	users[suid] = nil
end

function cmd.toast1( ... )
	-- body
	return toast1
end

function cmd.toast2( ... )
	-- body
	
end

function cmd.radio(text, ... )
	-- body
	local args = {}
	args.text = text
	for k,v in pairs(users) do
		skynet.send(v, "lua", "radio", args)
	end
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function (_, source, command, ... )
		-- body
		local f = assert(cmd[command])
		local r = f( ... )
		if r ~= noret then
			skynet.retpack(r)
		end
	end)
	skynet.register ".RADIOCENTER"
end)