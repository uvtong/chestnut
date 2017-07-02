package.path = "../../module/mahjong/lualib/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local sd = require "skynet.sharedata"
local redis = require "skynet.db.redis"

local dbmonitor = require "dbmonitor"
local log = require "log"
local snowflake = require "snowflake"
local const = require "const"
local noret = {}

local conf = {
	host = "127.0.0.1" ,
	port = 6379 ,
	db = 0
}

local CMD = {}

function CMD.start( ... )
	-- body
	snowflake.init(1)
	-- print(snowflake.next_id())
	-- print(snowflake.next_id())
	return true
end

function CMD.close( ... )
	-- body
	return true
end

function CMD.kill( ... )
	-- body
	skynet.exit()
end

function CMD.load( ... )
	-- body
	dbmonitor.cache_select('tb_count')
	dbmonitor.cache_select('tb_nameid')
	dbmonitor.cache_select('tb_openid')
	dbmonitor.cache_select('tb_record')
	dbmonitor.cache_select('tb_sysmail')
	dbmonitor.cache_select('tb_user')

	-- 2.0
	skynet.call(".SYSEMAIL", "lua", "load")
	skynet.call(".RECORD_MGR", "lua", "load")

	log.info("load over")
	return true
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		log.info("command = %s", command)
		local f = CMD[command]
		local r = f(...)
		if r ~= noret then
			skynet.ret(skynet.pack(r))
		end
	end)
	-- skynet.fork(update_db)
	skynet.register "game"
end)
