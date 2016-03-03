local skynet = require "skynet"
require "skynet.manager"
local loader = require "loader"

local game 
local D = {}

local CMD = {}

function CMD.enter_room(t)
	-- body
	local room = game.g_roommgr:get_by_csv_id
	local m = { user_id = t.user_id, addr = t.addr, room_id = room.csv_id}
	D[t.user_id] = m
	room:add(m)
	local r = {}
	for i,v in ipairs(room.__data) do
		if v.user_id = t.user_id then
			if i == 1 then
				if room.__data[2] then
					r.right = room.__data[2]
				elseif room.__data[3] then
					r.left = room.__data[3]
				end
			end
		end
	end
	return r
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
	skynet.register ".scene"
	game = loader.load_game()
end)