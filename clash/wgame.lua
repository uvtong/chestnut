package.path = "./../cat/?.lua;./../cat/lualib/?.lua;./../lualib/?.lua;" .. package.path
package.cpath = "./../cat/luaclib/?.so;./../lua-cjson/?.so;" .. package.cpath
local skynet = require "skynet"
local udpport = 1

local CMD = {}

function CMD.udp_port( ... )
	-- body
	udpport = udpport + 1
	return udpport
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		local result = f(...)
		if result then
			skynet.ret(skynet.pack(result))
		end
	end)
end)