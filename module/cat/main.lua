local skynet = require "skynet"
require "skynet.manager"
local assert = assert

skynet.start(function()
	local logger = skynet.uniqueservice("log")
	skynet.call(logger, "lua", "start")

	skynet.uniqueservice("protoloader")
	local console = skynet.newservice("console")
	-- skynet.newservice("debug_console",8000)
	skynet.newservice("codweb")

	local signupd = skynet.getenv("signupd")
	if signupd  then
		local conf = {
			db_host = skynet.getenv("db_host") or "192.168.1.116",
			db_port = skynet.getenv("db_port") or 3306,
			db_database = "user",
			db_user = skynet.getenv("db_user") or "root",
			db_password = skynet.getenv("db_password") or "yulei",
			cache_host = skynet.getenv("cache_host") or "192.168.1.116",
			cache_port = skynet.getenv("cache_port") or 6379
		}
		local db = skynet.newservice("db", "signup_db")
		assert(skynet.call(db, "lua", "start", conf))
		skynet.name(".signup_db", db)

		local signupd_name = skynet.getenv("signupd_name")
		local signupserver = skynet.newservice("signupserver", db)
		skynet.name(signupd_name, signupserver)
	end

	local logind = skynet.getenv("logind")
	if logind then
		local conf = {
			db_host = skynet.getenv("db_host") or "192.168.1.116",
			db_port = skynet.getenv("db_port") or 3306,
			db_database = "user",
			db_user = skynet.getenv("db_user") or "root",
			db_password = skynet.getenv("db_password") or "yulei",
			cache_host = skynet.getenv("cache_host") or "192.168.1.116",
			cache_port = skynet.getenv("cache_port") or 6379
		}

		local db = skynet.newservice("db", "logind_db")
		assert(skynet.call(db, "lua", "start", conf))
		skynet.name(".logind_db", db)

		local logindata = skynet.newservice("logindata")
		skynet.name(".logindata", logindata)
		local logind_name = skynet.getenv("logind_name")
		local loginserver = skynet.newservice("logind")
		skynet.name(logind_name, loginserver)
	end     

	local gated = skynet.getenv("gated")
	if gated then
		
		local conf = {
			db_host = skynet.getenv("db_host") or "192.168.1.116",
			db_port = skynet.getenv("db_port") or 3306,
			db_database = skynet.getenv("db_database") or "user",
			db_user = skynet.getenv("db_user") or "root",
			db_password = skynet.getenv("db_password") or "yulei",
			cache_host = skynet.getenv("cache_host") or "192.168.1.116",
			cache_port = skynet.getenv("cache_port") or 6379
		}

		local gated_wdb = skynet.getenv("gated_wdb")
		local wdb = skynet.newservice("db", "db")
		assert(skynet.call(wdb, "lua", "start", conf))
		skynet.name(gated_wdb, wdb) -- for forward.

		local gated_rdb = skynet.getenv("gated_rdb")
		local rdb = skynet.newservice("db", "rdb")
		assert(skynet.call(rdb, "lua", "start", conf))
		skynet.name(gated_rdb, rdb)

		-- write
		-- local wgame = skynet.newservice("wgame", db)
		-- skynet.name(".wgame", wgame)

		-- skynet.newservice("randomdraw")
		skynet.newservice("channel")

		-- read
		local game = skynet.uniqueservice("game")
		skynet.name(".game", game)

		skynet.newservice("simpledb")

		local leaderboards_name = skynet.getenv("leaderboards_name")
		local lb = skynet.newservice("leaderboards", "ara_leaderboards")
		skynet.name(leaderboards_name, lb)

		skynet.newservice("branch")

		local agent_mgr = skynet.newservice("agent_mgr")
		skynet.name(".agent_mgr", agent_mgr)

		local logind_name = skynet.getenv("logind_name")
		local server_name = skynet.getenv("gated_name")
		local max_client = skynet.getenv("maxclient")
		local address, port = string.match(skynet.getenv("gated"), "([%d.]+)%:(%d+)")
		local gated = skynet.newservice("gated")
		skynet.call(gated, "lua", "open", { 
			address = address or "0.0.0.0",
			port = port,
			maxclient = tonumber(max_client),
			servername = server_name,
			--nodelay = true,
		})
	end
	
	skynet.exit()
end)
