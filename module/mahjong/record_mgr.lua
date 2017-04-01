package.path = "./../../module/mahjong/lualib/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local noret = {}

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

function CMD.register(content, ... )
	-- body
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function (_, source, cmd, ... )
		-- body
		local f = assert(CMD[cmd])
		local msgh = function ( ... )
			-- body
			log.info(debug.traceback())
		end
		local ok, err = xpcall(f, msgh, ...)
		if ok then
			if err ~= noret then
				skynet.retpack(err)
			end
		end
	end)
	skynet.register ".RECORD_MGR"
end)