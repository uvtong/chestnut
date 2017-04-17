local query = require "query"
local const = require "const"
local log = require "log"

local tname = "tg_count"

local _M = {}

function _M.cache_select(db, ... )
	-- body
	-- 1.
	local sql = string.format("select * from tg_const where id = %d", const.UID_ID)
	local res = query.select(tname, sql)
	if #res > 0 then
		db:set(string.format("tg_count:%d:uid", const.UID_ID), res[1].uid)
	else
		db:set(string.format("tg_count:%d:uid", const.UID_ID), 0)
		local sql = "insert into tg_count (id, uid) values (%d, %d);"
		sql = string.format(sql, const.UID_ID, 0)
	end

	-- 2.
	local sql = string.format("select * from tg_const where id = %d", const.NAME_ID)
	local res = query.select(tname, sql)
	if #res > 0 then
		db:set(string.format("tg_count:%d:uid", const.NAME_ID), res[1].uid)
	else
		db:set(string.format("tg_count:%d:uid", const.NAME_ID), 0)
		local sql = "insert into tg_count (id, uid) values (%d, %d);"
		sql = string.format(sql, const.NAME_ID, 0)
	end	

	-- 4.
	local sql = string.format("select * from tg_const where id = %d", const.COUNT_RECORD_ID)
	local res = query.select(tname, sql)
	if #res > 0 then
		db:set(string.format("tg_count:%d:uid", const.COUNT_RECORD_ID), res[1].uid)
	else
		db:set(string.format("tg_count:%d:uid", const.COUNT_RECORD_ID), 0)
		local sql = "insert into tg_count (id, uid) values (%d, %d);"
		sql = string.format(sql, const.COUNT_RECORD_ID, 0)
	end	
end

function _M.cache_update(db, left, ... )
	-- body
	local id, key = left:match("([^:]+):(.+)")
	local val = db:get(string.format("tg_count:%s:%s", id, key))
	local sql = "update tg_count set %s = %s where id = %d;"
	sql = string.format(sql, key, math.tointeger(val), id)
	log.info(sql)
	query.update(tname, sql)
end

function _M.cache_insert(db, uid, ... )
	-- body
	assert(false)
	local suid = db:get(string.format("tg_uid:%s:suid", uid))
	local nickname_uid = db:get(string.format("tg_uid:%s:nickname_uid", uid))
	local sql = "insert into tg_uid (uid, suid, nickname_uid) values (%s, %d, %d);"
	sql = string.format(sql, uid, suid, nickname_uid)
	query.insert(tname, sql)
end

return _M