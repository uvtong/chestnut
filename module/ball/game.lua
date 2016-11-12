package.path = "../../module/ball/lualib/?.lua;../../module/ball/lualib/models/?.lua;"..package.path
package.cpath = "./../lua-cjson/?.so;" .. package.cpath
local skynet = require "skynet"
require "skynet.manager"
local sdbcontext = require "sdbcontext"

local sdb

local CMD = {}

function CMD.start( ... )
	-- body
	local rdb = ".DB"
	local wdb = ".DB"
	sdb = sdbcontext.new(true, rdb, wdb)
	sdb:load_db_to_data()
	sdb:load_data_to_sd()
end

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
		local f = CMD[command]
		local result = f(...)
		if result then
			skynet.ret(skynet.pack(result))
		end
	end)
	-- skynet.fork(update_db)
	skynet.register ".game"
end)
