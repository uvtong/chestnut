local query = require "query"
local log = require "log"

local tname = "tg_openid"

local _M = {}

function _M.cache_select(db, ... )
	-- body
	local sql = string.format("select * from %s", tname)
	local res = query.select(tname, sql)
	if #res > 0 then
		for _,row in pairs(res) do
			local openid = row.openid
			for k,v in pairs(res[1]) do
				db:set(string.format("%s:%s:%s", tname, openid, k), v)
			end
		end
	end
	return true
end

function _M.cache_update(db, uid, key, ... )
	-- body
	assert(false)
end

function _M.cache_insert(db, openid, ... )
	-- body
	local uid = db:get(string.format("%s:%s:uid", tname, openid))
	local sql = "insert into %s (openid, uid) values ('%s', %d);"
	sql = string.format(sql, tname, openid, uid)
	log.info(sql)
	query.insert(tname, sql)
end

function _M.cache_delete(db, uid, ... )
	-- body
end

return _M