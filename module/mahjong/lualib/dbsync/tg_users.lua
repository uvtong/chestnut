local query = require "query"
local log = require "log"

local tname = "tg_users"

local _M = {}

function _M.cache_select(db, ... )
	-- body
	local sql = string.format("select * from tg_users")
	local res = query.select(tname, sql)
	if #res > 0 then
		for k,v in pairs(res) do
			local uid = assert(v.uid)
			db:zadd(string.format('tg_users'), 1, uid)
			for kk,vv in pairs(v) do
				db:set(string.format("tg_users:%s:%s", uid, kk), vv)
			end
		end
	end
end

function _M.cache_update(db, left, ... )
	-- body
	local uid, key = left:match("([^:]+):(.+)")
	local val = db:get(string.format("tg_uid:%s:%s", uid, key))
	
	if key == 'rcard' or
		key == 'sex' then
		local sql = "update tg_users set %s = %s where uid = %s;"
		sql = string.format(sql, key, val, uid)
		query.update(tname, sql)
	else
		local sql = "update tg_users set %s = '%s' where uid = %s;"
		sql = string.format(sql, key, val, uid)
		query.update(tname, sql)
	end
end

function _M.cache_insert(db, uid, ... )
	-- body
	local gold           = db:get(string.format("tg_users:%d:gold", uid))
	local diamond        = db:get(string.format("tg_users:%d:diamond", uid))
	local checkin_month  = db:get(string.format("tg_users:%d:checkin_month", uid))
	local checkin_count  = db:get(string.format("tg_users:%d:checkin_count", uid))
	local checkin_mcount = db:get(string.format("tg_users:%d:checkin_mcount", uid))
	local checkin_lday   = db:get(string.format("tg_users:%d:checkin_lday", uid))
	local rcard          = db:get(string.format("tg_users:%d:rcard", uid))
	local sex            = db:get(string.format("tg_users:%d:sex", uid))
	local nickname       = db:get(string.format("tg_users:%d:nickname", uid))
	local province       = db:get(string.format("tg_users:%d:province", uid))
	local city           = db:get(string.format("tg_users:%d:city", uid))
	local country        = db:get(string.format("tg_users:%d:country", uid))
	local headimg        = db:get(string.format("tg_users:%d:headimg", uid))

	local sql = "insert into tg_users (uid, gold, diamond, checkin_month, checkin_count, checkin_mcount, checkin_lday, rcard, sex, nickname, province, city, country, headimg) values (%d, %d, %d, %d, %d, %d, %d, %d, %d, '%s', '%s', '%s', '%s', '%s')"
	sql = string.format(sql, uid, gold, diamond, checkin_month, checkin_count, checkin_mcount, checkin_lday, rcard, sex, nickname, province, city, country, headimg)
	log.info(sql)
	query.insert(tname, sql)
end

function _M.cache_delete( ... )
	-- body
end

return _M