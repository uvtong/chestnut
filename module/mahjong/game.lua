package.path = "../../module/mahjong/lualib/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local dbmonitor = require "dbmonitor"
local sd = require "sharedata"
local redis = require "redis"
local log = require "log"
local snowflak = require "snowflak"
local noret = {}

local conf = {
	host = "127.0.0.1" ,
	port = 6379 ,
	db = 0
}

local CMD = {}

function CMD.start( ... )
	-- body
	snowflak.init(0)
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
	dbmonitor.cache_select('tg_count')
	dbmonitor.cache_select('tg_record')
	dbmonitor.cache_select('tg_sysmail')
	dbmonitor.cache_select('tg_uid')
	dbmonitor.cache_select('tg_users')

	local db = redis.connect(conf)
	-- 1.0
	local keys = db:zrang('tg_record', 0, -1)
	for k,v in pairs(keys) do
		local vals = db:hgetall(string.format('tg_record:%s', v))
		for kk,vv in pairs(vals) do
			sd.new(string.format('tg_record:%s:%s', v, kk), vv)
		end
	end

	-- 2.0
	local idx =  db:get(string.format("tg_count:%d:uid", const.SYSMAIL_ID))
	if idx > 1 then
		local keys = db:zrang('tg_sysmail', 0, -1)
		for k,v in pairs(keys) do
			local vals = db:hgetall(string.format('tg_sysmail:%s', v))
			for kk,vv in pairs(vals) do
				sd.new(string.format('tg_sysmail:%s:%s', v, kk), vv)
			end
		end		
		skynet.call(".SYSEMAIL", "lua", "first")
	else
		skynet.call(".SYSEMAIL", "lua", "first_mail")
	end
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
