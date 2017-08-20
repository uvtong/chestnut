local query = require "query"
local log = require "skynet.log"

local tname = "tb_user"

local _M = {}

function _M.cache_select(db, ... )
	-- body
	local sql = string.format("select * from %s", tname)
	local res = query.select(tname, sql)
	if #res > 0 then
		for _,row in pairs(res) do
			local uid = assert(row.uid)
			db:zadd(tname, 1, uid)
			for kk,vv in pairs(row) do
				db:set(string.format("%s:%s:%s", tname, uid, kk), vv)
			end
		end
	end
	log.info("%s select over", tname)
	return true
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
	local gold           = db:get(string.format("%s:%d:gold", tname, uid))
	local diamond        = db:get(string.format("%s:%d:diamond", tname, uid))
	local checkin_month  = db:get(string.format("%s:%d:checkin_month", tname, uid))
	local checkin_count  = db:get(string.format("%s:%d:checkin_count", tname, uid))
	local checkin_mcount = db:get(string.format("%s:%d:checkin_mcount", tname, uid))
	local checkin_lday   = db:get(string.format("%s:%d:checkin_lday", tname, uid))
	local rcard          = db:get(string.format("%s:%d:rcard", tname, uid))
	local sex            = db:get(string.format("%s:%d:sex", tname, uid))
	local nickname       = db:get(string.format("%s:%d:nickname", tname, uid))
	local province       = db:get(string.format("%s:%d:province", tname, uid))
	local city           = db:get(string.format("%s:%d:city", tname, uid))
	local country        = db:get(string.format("%s:%d:country", tname, uid))
	local headimg        = db:get(string.format("%s:%d:headimg", tname, uid))

	local sql = "insert into %s (uid, gold, diamond, checkin_month, checkin_count, checkin_mcount, checkin_lday, rcard, sex, nickname, province, city, country, headimg) values (%d, %d, %d, %d, %d, %d, %d, %d, %d, '%s', '%s', '%s', '%s', '%s')"
	sql = string.format(sql, tname, uid, gold, diamond, checkin_month, checkin_count, checkin_mcount, checkin_lday, rcard, sex, nickname, province, city, country, headimg)
	log.info(sql)
	query.insert(tname, sql)
end

function _M.cache_delete( ... )
	-- body
end

return _M