local log = require "skynet.log"
local query = require "query"
local const = require "const"


local tname = "tb_count"

local function new_item(db, id, ... )
	-- body
	assert(id)
	local sql = string.format("select * from %s where id = %d", tname, id)
	log.info(sql)
	local res = query.select(tname, sql)
	if #res > 0 then
		db:set(string.format("%s:%d:uid", tname, id), assert(res[1].uid))
	else
		db:set(string.format("%s:%d:uid", tname, id), 0)
		local sql = string.format("insert into %s (id, uid) values (%d, %d);", tname, id, 0)
		query.insert(tname, sql)
	end
end

local _M = {}

function _M.cache_select(db, ... )
	-- body
	assert(db)
	-- 1.
	new_item(db, const.UID_ID)
	new_item(db, const.NAME_ID)
	new_item(db, const.SYSMAIL_ID)
	new_item(db, const.RECORD_ID)

	return true
end

function _M.cache_update(db, left, ... )
	-- body
	local id, key = left:match("([^:]+):(.+)")
	local val = db:get(string.format("%s:%s:%s", tname, id, key))
	local sql = "update %s set %s = %s where id = %d;"
	sql = string.format(sql, tname, key, math.tointeger(val), id)
	assert(sql ~= '')
	log.info(sql)
	query.update(tname, sql)
end

function _M.cache_insert(db, uid, ... )
	-- body
	assert(false)
end

function _M.cache_delete(db, ... )
	-- body
end

return _M