local query = require "query"
local log = require "log"

local tname = "tg_uid"

local _M = {}

function _M.cache_select(db, uid, ... )
	-- body

	local sql = string.format("select * from tg_uid where uid = %s", uid)
	local res = query.select(tname, sql)
	assert(#res > 0)
	for k,v in pairs(res[1]) do
		db:set(string.format("tg_uid:%s:%s", uid, k), v)
	end
end

function _M.cache_update(db, uid, key, ... )
	-- body
	local val = db:get(string.format("tg_uid:%s:%s", uid, key))
	if type(val) == "number" then
		local sql = "update tg_uid set %s = %s where uid = %d;"
		sql = string.format(sql, key, val, uid)
		log.info(sql)
		query.update(tname, sql)
	end
end

function _M.cache_insert(db, uid, ... )
	-- body
	local suid = db:get(string.format("tg_uid:%s:suid", uid))
	local nickname_uid = db:get(string.format("tg_uid:%s:nickname_uid", uid))
	local sql = "insert into tg_uid (uid, suid, nickname_uid) values ('%s', %d, %d);"
	sql = string.format(sql, uid, suid, nickname_uid)
	log.info(sql)
	query.insert(tname, sql)
end

function _M.cache_delete(db, uid, ... )
	-- body
end

return _M