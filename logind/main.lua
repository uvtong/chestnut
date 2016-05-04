local skynet = require "skynet"
require "skynet.manager"
local sprotoloader = require "sprotoloader"
local assert = assert

skynet.start(function()
	skynet.uniqueservice("protoloader")
	local console = skynet.newservice("console")
	-- skynet.newservice("debug_console",8000)
	skynet.newservice("simpledb")

	local conf = {
		db_host = skynet.getenv("db_host") or "192.168.1.116",
		db_port = skynet.getenv("db_port") or 3306,
		db_database = skynet.getenv("db_database") or "user",
		db_user = skynet.getenv("db_user") or "root",
		db_password = skynet.getenv("db_password") or "yulei",
		cache_host = skynet.getenv("cache_host") or "192.168.1.116",
		cache_port = skynet.getenv("cache_port") or 6379
	}
	local db = skynet.newservice("db")
	local ok = skynet.call(db, "lua", "start", conf)
	assert(ok)
	skynet.name(".db", db) -- for forward.
	
    local server_name = skynet.getenv("servername")
    local max_client = skynet.getenv("maxclient") or 64
    local logind_name = skynet.getenv("logind_name")

    if skynet.getenv("standalone") then
    	local conf = {
			db_host = "192.168.1.116",
			db_port = 3306,
			db_database = "user",
			db_user = "root",
			db_password = "yulei",
			cache_host = "192.168.1.116",
			cache_port = 6379,
		}
		local db = skynet.newservice("db")
		assert(skynet.call(db, "lua", "start", conf))
		skynet.name(".signup_db", db)
		local signupserver = skynet.newservice("signupserver", db)
		skynet.name(".signupd", signupserver)

		local loginserver = skynet.newservice("logind")
		skynet.name(logind_name, loginserver)
	end

	local leaderboards_name = skynet.getenv("leaderboards_name")
	local lb = skynet.newservice("leaderboards")
	skynet.name(leaderboards_name, lb)

	local game = skynet.newservice("game", db)
	skynet.name(".game", game)

	local channel = skynet.newservice("channel", game)
	skynet.name(".channel", channel)
	
	local logintimes = skynet.newservice("logintimes", db)
	skynet.name(".logintimes", logintimes)

	local gated = skynet.newservice("gated", logind_name)
	local address, port = string.match(skynet.getenv("gated"), "([%d.]+)%:(%d+)")
	skynet.call(gated, "lua", "open", { 
		address = address or "0.0.0.0",
		port = port,
		maxclient = tonumber(max_client),
		servername = server_name,
		--nodelay = true,
	})
	skynet.exit()
end)
