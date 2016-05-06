package.path = "./../cat/?.lua;./../cat/lualib/?.lua;./../lualib/?.lua;" .. package.path
package.cpath = "./../cat/luaclib/?.so;" .. package.cpath
local skynet = require "skynet"
require "skynet.manager"

local function update_db()
	-- body
	while true do
		if game then
			game.g_uidmgr:update_db(const.DB_PRIORITY_3)
			game.g_randomvalmgr:update_db(const.DB_PRIORITY_3)
		end
		skynet.sleep(100 * 60) -- 1ti == 0.01s
	end
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		print("called", command)
		local f = CMD[command]
		local result = f(...)
		if result then
			skynet.ret(skynet.pack(result))
		end
	end)
	game = loader.load_game()
	-- skynet.fork(update_db)
end)