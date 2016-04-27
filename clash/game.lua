package.path = "./../clash/?.lua;./../clash/lualib/?.lua;../lualib/?.lua;"..package.path
package.cpath = "./../clash/luaclib/?.so;"..package.cpath
local skynet = require "skynet"
require "skynet.manager"
local loader = require "loader"
-- local tptr = require "tablepointer"
-- local const = require "const"
local game
local db = tonumber(...)

local CMD = {}

local function abc()
	-- body
	local x = "a"
	while true do
		if game.g_achievementmgr then
			print(game.g_achievementmgr:get_by_csv_id(1001).reward)
			x = x .. "a"
			game.g_achievementmgr:get_by_csv_id(1001).reward = x
		end
		skynet.sleep(500)
	end
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		print("called", command)
		local f = CMD[command]
		local r = f(...)
		if r then
			skynet.ret(skynet.pack(r))
		end
	end)
	game = loader.load_game()
	-- skynet.fork(abc)
end)
