local skynet = require "skynet"
require "skynet.manager"
local errorcode = require "errorcode"

local game

local CMD = {}

function CMD.enter_room(t)
	-- body
	local room = game.g_roommgr.get_next()
	table.insert(room.users, room)
	for i,v in ipairs(room.users) do
		print(i,v)
	end
	local ret = { name="left", addr=2, user_id=1}
	return ret
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
	skynet.register ".scene"
end)