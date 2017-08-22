local query = require "query"
local log = require "skynet.log"
local util = require "util"

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
	local val = db:get(string.format("tb_uid:%s:%s", uid, key))
	
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
	log.info("tb_user uid = %s", uid)
	local cmd = string.format("%s:%s", tname, uid)
	log.info("cmd = %s", cmd)
	local hval = db:hgetall(cmd)
	local h = util.redis_hval(hval)

	local sql = "insert into %s (uid, nickname, sex) values (%s, '%s', %s)"
	sql = string.format(sql, tname, h.uid, h.nickname, h.sex)
	log.info(sql)
	query.insert(tname, sql)
end

function _M.cache_delete( ... )
	-- body
end

return _M