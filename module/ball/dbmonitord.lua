local skynet = require "skynet"
require "skynet.manager"
local redis = require "skynet.db.redis"
local log = require "skynet.log"
local query = require "query"
local util = require "util"
local const = require "const"
local tb_count = require "dbsync.tb_count"
-- local tb_nameid = require "dbsync.tb_nameid"
local tb_openid = require "dbsync.tb_openid"
-- local tb_record = require "dbsync.tb_record"
-- local tb_sysmail = require "dbsync.tb_sysmail"
local tb_user = require "dbsync.tb_user"
-- local tb_user_achievement = require "dbsync.tb_user_achievement"
-- local tb_user_checkindaily = require "dbsync.tb_user_checkindaily"
-- local tb_user_inbox = require "dbsync.tb_user_inbox"
-- local tb_user_record = require "dbsync.tb_user_record"
-- local tb_user_sysmail = require "dbsync.tb_user_sysmail"
-- local tb_user_task = require "dbsync.tb_user_task"

local users = {}

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
	log.info(string.format("tname = %s", tname))
	if tname == 'tb_count' then
		return tb_count.cache_select(db, left)
	elseif tname == 'tb_nameid' then
		return tb_nameid.cache_select(db, left)
	elseif tname == 'tb_openid' then
		return tb_openid.cache_select(db, left)
	elseif tname == 'tb_record' then
		return tb_record.cache_select(db, left)
	elseif tname == 'tb_sysmail' then
		return tb_sysmail.cache_select(db, left)
	elseif tname == 'tb_user' then
		return tb_user.cache_select(db, left)
	elseif tname == 'tb_user_achievement' then
		return tb_user_achievement.cache_select(db, left)
	elseif tname == 'tb_user_checkindaily' then
		return tb_user_checkindaily.cache_select(db, left)
	elseif tname == 'tb_user_inbox' then
		return tu_inbox.cache_select(db, left)
	elseif tname == 'tb_user_record' then
		return tb_user_record.cache_select(db, left)
	elseif tname == 'tb_user_sysmail' then
		return tb_user_sysmail.cache_select(db, left)
	elseif tname == 'tb_user_task' then
		return tb_user_task.cache_select(db, left)
	end
end

function CMD.cache_update(key, ... )
	-- body
	local tname, left = key:match("([^:]+):(.+)")
	log.info(string.format("update tname = %s", tname))
	if tname == 'tb_count' then
		tb_count.cache_update(db, left, ...)
	elseif tname == 'tb_record' then
		tb_record.cache_update(db, left, ...)
	elseif tname == 'tb_sysmail' then
		tb_sysmail.cache_update(db, left, ...)
	elseif tname == "tg_user" then
		tb_user.cache_update(db, left, ...)
	elseif tname == 'tu_record' then
		tu_record.cache_update(db, left, ...)
	elseif tname == 'tu_sysmail' then
		tu_sysmail.cache_update(db, left, ...)
	elseif tname == 'tu_task' then
		tu_task.cache_update(db, left, ...)
	end
	return noret
end

function CMD.cache_insert(key, ... )
	-- body
	local tname, left = key:match("([^:]+):(.+)")
	log.info(string.format("insert tname = %s", tname))
	if tname == 'tb_count' then
		tb_count.cache_insert(db, left)
	elseif tname == 'tb_nameid' then
		tb_nameid.cache_insert(db, left)
	elseif tname == 'tb_openid' then
		tb_openid.cache_insert(db, left)
	elseif tname == 'tb_record' then
		tb_record.cache_insert(db, left)
	elseif tname == 'tb_sysmail' then
		tb_sysmail.cache_insert(db, left)
	elseif tname == 'tb_user' then
		tb_user.cache_insert(db, left)
	elseif tname == 'tu_record' then
		tb_user_record.cache_insert(db, left)
	elseif tname == 'tu_sysmail' then
		tb_user_sysmail.cache_insert(db, left)
	elseif tname == 'tu_task' then
		tb_user_task.cache_insert(db, left)
	end
	return noret
end

function CMD.login(uid, ... )
	-- body
	local cancel = users[uid]
	if cancel then
		cancel()
	end
end

function CMD.logout(uid, ... )
	-- body
	local cancel = util.set_timeout(const.AGENT_TIMEOUT, function ( ... )
		-- body
		tb_user_achievement.cache_delete(db, uid)
		tb_user_checkindaily.cache_delete(db, uid)
		tb_user_inbox.cache_delete(db, uid)
		tb_user_record.cache_delete(db, uid)
		tb_user_sysmail.cache_delete(db, uid)
	end)
	users[uid] = cancel
end

function CMD.afx(uid, ... )
	-- body
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