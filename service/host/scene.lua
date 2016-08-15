local skynet = require "skynet"
require "skynet.manager"
local loader = require "loader"



local CMD = {}

function CMD.enter( ... )
	-- body
end

function CMD.enter_room(t)
	-- body
	local room = game.g_roommgr:get_next()
	assert(#room.__data < 3)  
	local m = { user_id = t.user_id, addr = t.addr, room_id = room.csv_id}
	D[t.user_id] = m
	room:add(m)
	if #room.__data == 1 then
		return {}
	else #room.__data == 2 then
		skynet.send(room.__data[1].addr, "lua", "enter_room", { right = room.__data[2])
		return { left = room.__data[1]}
	else #room.__data == 3 then
		skynet.send(room.__data[1].addr, "lua", "enter_room", { left = room.__data[3])
		skynet.send(room.__data[2].addr, "lua", "enter_room", { right = room.__data[3])
		return { left = room.__data[2], right = room.__data[1]}
	else
		assert(false)
	end
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
	skynet.register ".SCENE"
	game = loader.load_game()
end)