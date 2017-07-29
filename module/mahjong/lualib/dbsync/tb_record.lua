local query = require "query"
local const = require "const"
local log = require "skynet.log"

local tname = "tb_record"

local _M = {}

function _M.cache_select(db, ... )
	-- body

	-- 1.
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
	local sql = "insert into %s (id, content, datetime, idx1, idx2, idx3, idx4) values (%s, '%s', %s);"
	sql = string.format(sql, tname, left, vals.content, vals.datetime, vals.idx1, vals.idx2, vals.idx3, vals.idx4)
	log.info(sql)
	query.insert(tname, sql)
end

function _M.cache_delete(db, ... )
	-- body
end

return _M