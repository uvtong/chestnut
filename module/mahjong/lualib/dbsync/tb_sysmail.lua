local query = require "query"
local const = require "const"
local log = require "skynet.log"

local tname = "tb_sysmail"

local _M = {}

function _M.cache_select(db, ... )
	-- body
	local sql = string.format("select * from %s", tname)
	local res = query.select(tname, sql)
	if #res > 0 then
		for _,row in pairs(res) do
			local id = row.id
			assert(id)
			db:zadd(tname, 1, id)
			for kk,vv in pairs(row) do
				db:hset(string.format("%s:%d", tname, id), kk, vv)
			end
		end
	end
	return true
end

function _M.cache_update(db, left, ... )
	-- body
	assert(false)
end

function _M.cache_insert(db, left, ... )
	-- body
	local vals = db:hgetall(string.format("%s:%s", tname, left))
	local sql = "insert into %s (id, datetime, title, content) values (%s, %s, '%s', '%s');"
	sql = string.format(sql, tname, left, vals.datetime, vals.title, vals.content)
	log.info(sql)
	query.insert(tname, sql)
end

function _M.cache_delete(db, ... )
	-- body
end

return _M