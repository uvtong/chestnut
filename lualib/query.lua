local skynet = require "skynet"
local db = skynet.localname(".db")

local _M = {
	DB_PRIORITY_1 = 1,
	DB_PRIORITY_2 = 2,
	DB_PRIORITY_3 = 3
}

function _M.select_sql_wait(table_name, sql, priority)
	-- body
	return skynet.call(db, "lua", "command", "select_sql_wait", table_name, sql, priority)
end

function _M.update_sql(table_name, sql, priority)
	-- body
	skynet.send(db, "lua", "command", "update_sql", table_name, sql, priority)
end

function _M.insert_sql(table_name, sql, priority)
	-- body
	skynet.send(db, "lua", "command", "insert_sql", table_name, sql, priority)
end

function _M.insert_all_sql(table_name, sql, priority)
	skynet.send(db, "lua", "command", "insert_all_sql", table_name, sql, priority)
end

function _M.update_all_sql(table_name, sql, priority)
	-- body
	skynet.send(db, "lua", "command", "update_all_sql", table_name, sql, priority)
end
	
return _M