package.path = "./../../module/mahjong/agent/?.lua;./../../module/mahjong/lualib/?.lua;"..package.path
local skynet = require "skynet"

local noret = {}
local CMD = {}

function CMD.start( ... )
	-- body
end

function CMD.close( ... )
	-- body
end

function CMD.exit( ... )
	-- body
end

skynet.start(function()
	skynet.dispatch("lua", function(_, source, cmd, ...)
		local f = assert(CMD[cmd])
		local ok, err = pcall(f, ...) 
		if ok then
			if err ~= noret then
				skynet.retpack(err)
			end
		else
			log.error(err)
		end
	end)
end)