package.path = "./../../module/mahjong/lualib/?.lua;../../lualib/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local log = require "log"
local redis = require "redis"
local query = require "query"
local tg_count = require "dbsync.tg_count"
local tg_record = require "dbsync.tg_record"
local tg_sysmail = require "dbsync.tg_sysmail"
local tg_uid = require "dbsync.tg_uid"
local tg_users = require "dbsync.tg_users"
local tu_achievement = require "dbsync.tu_achievement"
local tu_count = require "dbsync.tu_count"
local tu_inbox = require "dbsync.tu_inbox"
local tu_record = require "dbsync.tu_record"
local tu_sysmail = require "dbsync.tu_sysmail"
local tu_task = require "dbsync.tu_task"

local conf = {
	host = "127.0.0.1" ,
	port = 6379 ,
	db = 0
}

local db

local CMD = {}

function CMD.start( ... )
	-- body
	db = redis.connect(conf)

	skynet.call('game', 'lua', 'load')
	
	return true
end

function CMD.close( ... )
	-- body
	db:disconnect()
	return true
end

function CMD.kill( ... )
	-- body
	skynet.exit()
end

function CMD.cache_select(key, ... )
	-- body
	log.info("cache_select key = %s", key)
	local tname, left = key:match("([^:]+):(.+)")
	if tname == nil then
		tname = key
	end
	if tname == 'tg_count' then
		return tg_count.cache_select(db, left)
	elseif tname == 'tg_record' then
		return tg_record.cache_select(db, left)
	elseif tname == 'tg_sysmail' then
		return tg_sysmail.cache_select(db, left)
	elseif tname == 'tg_uid' then
		return tg_uid.cache_select(db, left)
	elseif tname == 'tg_users' then
		return tg_users.cache_select(db, left)
	elseif tname == 'tu_achievement' then
		return tu_achievement.cache_select(db, left)
	elseif tname == 'tu_checkindaily' then
		return tu_checkindaily.cache_select(db, left)
	elseif tname == 'tu_count' then
		return tu_count.cache_select(db, left)
	elseif tname == 'tu_inbox' then
		return tu_inbox.cache_select(db, left)
	elseif tname == 'tu_record' then
		return tg_record.cache_select(db, left)
	elseif tname == 'tu_sysmail' then
		return tu_sysmail.cache_select(db, left)
	elseif tname == 'tu_task' then
		return tu_task.cache_select(db, left)
	end
end

function CMD.cache_update(key, ... )
	-- body
	local tname, left = key:match("([^:]+):(.+)")
	if tname == 'tg_count' then
		tg_count.cache_update(db, left, ...)
	elseif tname == 'tg_record' then
		tg_record.cache_update(db, left, ...)
	elseif tname == 'tg_sysmail' then
		tg_sysmail.cache_update(db, left, ...)
	elseif tname == 'tg_uid' then
		tg_uid.cache_update(db, left, ...)
	elseif tname == "tg_users" then
		tg_users.cache_update(db, left, ...)
	elseif tname == 'tu_record' then
		tu_record.cache_update(db, left, ...)
	elseif tname == 'tu_sysmail' then
		tu_sysmail.cache_update(db, left, ...)
	elseif tname == 'tu_task' then
		tu_task.cache_update(db, left, ...)
	end
end

function CMD.cache_insert(key, ... )
	-- body
	local tname, left = key:match("([^:]+):(.+)")
	if tname == 'tg_count' then
		tg_count.cache_insert(db, left)
	elseif tname == 'tg_record' then
		tg_record.cache_insert(db, left)
	elseif tname == 'tg_sysmail' then
		tg_sysmail.cache_insert(db, left)
	elseif tname == 'tg_uid' then
		tg_uid.cache_insert(db, left)
	elseif tname == "tg_users" then
		tg_users.cache_insert(db, left)
	elseif tname == 'tu_record' then
		tu_record.cache_insert(db, left)
	elseif tname == 'tu_sysmail' then
		tu_sysmail.cache_insert(db, left)
	elseif tname == 'tu_task' then
		tu_task.cache_insert(db, left)
	end
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function (_, source, cmd, ... )
		-- body
		log.info("cmd = " .. cmd)
		local f = assert(CMD[cmd])
		local r = f( ... )
		if r ~= noret then
			skynet.retpack(r)
		end
	end)
	skynet.register "DBMONITOR"
end)