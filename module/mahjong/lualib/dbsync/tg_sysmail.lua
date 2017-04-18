local query = require "query"
local const = require "const"
local log = require "log"

local tname = "tg_sysmail"

local _M = {}

function _M.cache_select(db, ... )
	-- body
	local sql = string.format("select * from tg_sysmail")
	local res = query.select(tname, sql)
	if #res > 0 then
		for k,v in pairs(res) do
			local id = v.id
			assert(id)
			db:zadd("tg_sysmail", 1, id)
			for kk,vv in pairs(v) do
				db:hset(string.format("tg_sysmail:%d", id), kk, vv)
			end
		end
	end
	return true
end

function _M.cache_update(db, left, ... )
	-- body
	assert(false)
	local id, key = left:match("([^:]+):(.+)")
	local val = db:get(string.format("tg_count:%s:%s", id, key))
	local sql = "update tg_count set %s = %s where id = %d;"
	sql = string.format(sql, key, math.tointeger(val), id)
	log.info(sql)
	query.update(tname, sql)
end

function _M.cache_insert(db, left, ... )
	-- body
	local vals = db:hgetall(string.format("tg_sysmail:%s", left))
	local sql = "insert into tg_sysmail (id, datetime, title, content) values (%s, %s, '%s', '%s');"
	sql = string.format(sql, left, vals.datetime, vals.title, vals.content)
	log.info(sql)
	query.insert(tname, sql)
end

function _M.cache_delete(db, ... )
	-- body
end

return _M