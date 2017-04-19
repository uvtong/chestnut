local query = require "query"
local log = require "log"

local tname = "tu_sysmail"

local _M = {}

function _M.cache_select(db, uid, ... )
	-- body
	assert(db and uid)
	local sql = string.format("select * from tu_sysmail where uid = %s", uid)
	local res = query.select(tname, sql)
	if #res > 0 then
		for k,v in pairs(res) do
			local id = assert(v.id)
			db:zadd(string.format('tu_sysmail:%s', uid), 1, id)

			for kk,vv in pairs(v) do
				db:hset(string.format('tu_sysmail:%s:%s', uid, id), kk, vv)
			end
		end
	end
end

function _M.cache_update(db, left, key, ... )
	-- body
	assert(db and left and key)
	local val = db:hget(string.format("tu_sysmail:%s", left), key)

	local sql = "update tu_sysmail set %s = %s where id = %d;"
	sql = string.format(sql, key, val, id)
	log.info(sql)
	query.update(tname, sql)

end

function _M.cache_insert(db, left, ... )
	-- body
	local uid, id = left:match("([^:]+):(.+)")
	local vals = db:hgetall(string.format("tu_sysmail:%s:%s", uid, id))

	local t = {}
	for i=1,#vals,2 do
		t[vals[i]] = vals[i+1]
	end

	local sql = "insert into tu_sysmail (id, uid, mailid, datetime, viewed) values (%s, %s, %s, %s, %s);"
	sql = string.format(sql, id, uid, t.mailid, t.datetime, t.viewed)
	log.info(sql)
	query.insert(tname, sql)
end

function _M.cache_delete(db, uid, ... )
	-- body
	local keys = db:zrang(string.format("tu_sysmail:%s", uid), 0, -1)
	for k,v in pairs(keys) do
		db:del(string.format("tu_sysmail:%s:%s", uid, v))
	end

end

return _M