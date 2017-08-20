local query = require "query"
local log = require "skynet.log"

local tname = "tb_user_achievement"

local _M = {}

function _M.cache_select(db, uid, ... )
	-- body

	local sql = string.format("select * from %s where uid=%d", tname, uid)
	local res = query.select(tname, sql)
	if #res > 0 then
		for k,v in pairs(res) do
			local id = v.id
			assert(id)
			db:zadd('tu_achievement', 1, id)

			for kk,vv in pairs(v) do
				db:hset(string.format('tu_achievement:%s', id), kk, vv)
			end
		end
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