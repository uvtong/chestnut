local query = require "query"
local log = require "skynet.log"

local tname = "tb_nameid"

local _M = {}

function _M.cache_select(db, ... )
	-- body
	local sql = string.format("select * from %s", tname)
	local res = query.select(tname, sql)
	if #res > 0 then
		for _,row in pairs(res) do
			local nameid = row.nameid
			for k,v in pairs(res[1]) do
				db:set(string.format("%s:%s:%s", tname, nameid, k), v)
			end	
		end
	end
	return true
end

function _M.cache_update(db, uid, key, ... )
	-- body
	assert(false)
end

function _M.cache_insert(db, nameid, ... )
	-- body
	local uid = db:get(string.format("%s:%s:uid", tname, nameid))
	local sql = "insert into %s (nameid, uid) values ('%s', %d);"
	sql = string.format(sql, tname, nameid, uid)
	log.info(sql)
	query.insert(tname, sql)
end

function _M.cache_delete(db, uid, ... )
	-- body
end

return _M