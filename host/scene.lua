local skynet = require "skynet"
require "skynet.manager"

local game

local CMD = {}

function CMD.enter_room(t)
	-- body
	for k,v in pairs(game.g_roommgr.__data) do
		if v.is_empty == 1 then
			return v.csv_id
		end
	end
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
	skynet.register ".scene"
end)