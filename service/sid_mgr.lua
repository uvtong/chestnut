local skynet = require "skynet"
require "skynet.manager"
local log = require "log"

local id = 1

local cmd = {}

function cmd.start( ... )
	-- body
	return true
end

function cmd.kill( ... )
	-- body
	skynet.exit()
end

function cmd.enter( ... )
	-- body
	id = id + 1
	return id
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function (_, source, command, ...)
		local f = cmd[command]
		local ok, err = pcall(f, ...)
		if ok then
			if err ~= nil then
				skynet.retpack(err)
			end
		else
			log.error(err)
		end
	end)
	skynet.register ".SID_MGR"
end)
