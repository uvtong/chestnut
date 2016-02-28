local skynet = require "skynet"
require "skynet.manager"
local CMD = {}
local q = {}
local rooms = {}

function CMD.enter_room(t)
	-- body
	for k,v in pairs(t) do
		table.insert(q, k)
	end

end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
	skynet.register ".scene"
end)