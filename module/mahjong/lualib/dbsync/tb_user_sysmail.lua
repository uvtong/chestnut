local query = require "query"
local log = require "skynet.log"

local tname = "tb_user_sysmail"

local _M = {}

function _M.cache_select(db, uid, ... )
	-- body
	assert(db and uid)
	local sql = string.format("select * from %s where uid = %s", tname, uid)
	local res = query.select(tname, sql)
	if #res > 0 then
		for _,row in pairs(res) do
			local id = assert(row.id)
			db:zadd(string.format('%s:%s', tname, uid), 1, id)

			for kk,vv in pairs(v) do
				db:hset(string.format('%s:%s:%s', tname, uid, id), kk, vv)
			end
		end
	end
end

function _M.cache_update(db, left, key, ... )
	-- body
	print(left)
	print(key)
	assert(db and left and key)
	local uid, id = left:match("([^:]+):(.+)")
	local val = db:hget(string.format("%s:%s", tname, left), key)

	local sql = string.format("update %s set %s = %s where id = %s;", tname, key, val, id)
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

	local sql = "insert into %s (id, uid, mailid, viewed) values (%s, %s, %s, %s);"
	sql = string.format(sql, tname, id, uid, t.mailid, t.viewed)
	log.info(sql)
	query.insert(tname, sql)
end

function _M.cache_delete(db, uid, ... )
	-- body
	local keys = db:zrang(string.format("%s:%s", tname, uid), 0, -1)
	for k,v in pairs(keys) do
		db:del(string.format("tu_sysmail:%s:%s", uid, v))
	end

end

return _M