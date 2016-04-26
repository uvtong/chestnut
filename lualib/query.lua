local skynet = require "skynet"

local _M = {
	DB_PRIORITY_1 = 1,
	DB_PRIORITY_2 = 2,
	DB_PRIORITY_3 = 3
}

function _M.select_sql_wait(db, table_name, sql, priority)
	-- body
	return skynet.send(db, "query", sql)
end

function _M.update_sql(db, table_name, sql, priority)
	-- body
	skynet.send(db, "lua", "update_sql", table_name, sql, priority)
end

function _M.insert_sql(db, table_name, sql, priority)
	-- body
	skynet.send(db, "lua", "insert_sql", table_name, sql, priority)
end

function _M.insert_all_sql(db, table_name, sql, priority)
	skynet.send(db, "lua", "insert_all_sql", table_name, sql, priority)
end

function _M.update_all_sql(db, table_name, sql, priority)
	-- body
	skynet.send(db, "lua", "update_all_sql", table_name, sql, priority)
end
	
return _M