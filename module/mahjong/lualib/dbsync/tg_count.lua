local query = require "query"
local const = require "const"
local log = require "log"

local tname = "tg_count"

local function new_item(db, id, ... )
	-- body
	assert(id)
	local sql = "select * from tg_count where id = %d"
	sql = string.format(sql, id)
	log.info(sql)
	local res = query.select(tname, sql)
	if #res > 0 then
		db:set(string.format("tg_count:%d:uid", id), assert(res[1].uid))
	else
		db:set(string.format("tg_count:%d:uid", id), 0)
		local sql = "insert into tg_count (id, uid) values (%d, %d);"
		query.insert(tname, sql)
	end
end

local _M = {}

function _M.cache_select(db, ... )
	-- body
	assert(db)
	-- 1.
	new_item(db, const.UID_ID)
	new_item(db, const.NAME_ID)
	new_item(db, const.SYSMAIL_ID)
	new_item(db, const.COUNT_RECORD_ID)

	return true
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

function _M.cache_delete(db, ... )
	-- body
end

return _M