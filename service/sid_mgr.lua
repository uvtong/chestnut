local skynet = require "skynet"
require "skynet.manager"
local log = require "skynet.log"

local internal_id = 1

local cmd = {}

function cmd.start( ... )
	-- body
	return true
end

function cmd.close( ... )
	-- body
	return true
end

function cmd.enter( ... )
	-- body
	internal_id = internal_id + 1
	return internal_id
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