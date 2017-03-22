package.path = "./../../module/mahjong/lualib/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local noret = {}

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function (_, source, cmd, ... )
		-- body
		local f = assert(CMD[cmd])
		local r = f(source, ...)
		if r ~= noret then
			skynet.retpack(r)
		end
	end)
	skynet.register ".RECORD_MGR"
end)