local skynet = require "skynet"
require "skynet.manager"
local sprotoloader = require "sprotoloader"
local assert = assert

skynet.start(function()
	skynet.uniqueservice("protoloader")
	local console = skynet.newservice("console")
	-- skynet.newservice("debug_console",8000)

	local conf = {
		db_host = skynet.getenv("db_host") or "192.168.1.116",
		db_port = skynet.getenv("db_port") or 3306,
		db_database = skynet.getenv("db_database") or "user",
		db_user = skynet.getenv("db_user") or "root",
		db_password = skynet.getenv("db_password") or "yulei",
		cache_host = skynet.getenv("cache_host") or "192.168.1.116",
		cache_port = skynet.getenv("cache_port") or 6379
	}

	local wdb = skynet.newservice("db")
	assert(skynet.call(wdb, "lua", "start", conf))
	skynet.name(".db", wdb) -- for forward.

	local rdb = skynet.newservice("db")
	assert(skynet.call(rdb, "lua", "start", conf))
	skynet.name(".rdb", rdb)

	local signupd = skynet.getenv("signupd")
	if signupd  then
		local conf = {
			db_host     = "192.168.1.116",
			db_port     = 3306,
			db_database = "user",
			db_user     = "root",
			db_password = "yulei",
			cache_host  = "192.168.1.116",
			cache_port  = 6379,
		}
		local db = skynet.newservice("db")
		assert(skynet.call(db, "lua", "start", conf))
		skynet.name(".signup_db", db)
		local signupd_name = skynet.getenv("signupd_name")
		local signupserver = skynet.newservice("signupserver", db)
		skynet.name(signupd_name, signupserver)
	end

	local logind = skynet.getenv("logind")
	if logind then
		local conf = {
			db_host     = "192.168.1.116",
			db_port     = 3306,
			db_database = "user",
			db_user     = "root",
			db_password = "yulei",
			cache_host  = "192.168.1.116",
			cache_port  = 6379,
		}
		local db = skynet.newservice("db")
		assert(skynet.call(db, "lua", "start", conf))
		skynet.name(".logind_rdb", db)

		local db = skynet.newservice("db")
		assert(skynet.call(db, "lua", "start", conf))
		skynet.name(".logind_wdb", db)

		local logindata = skynet.newservice("logindata")
		skynet.name(".logindata", logindata)
		local logind_name = skynet.getenv("logind_name")
		local loginserver = skynet.newservice("logind", db)
		skynet.name(logind_name, loginserver)
	end

	local gated = skynet.getenv("gated")
	if gated then
		
		-- write
		local wgame = skynet.newservice("wgame", db)
		skynet.name(".wgame", wgame)

		-- read
		local game = skynet.newservice("game")
		skynet.name(".game", game)

		skynet.newservice("simpledb")

		local leaderboards_name = skynet.getenv("leaderboards_name")
		local lb = skynet.newservice("leaderboards", leaderboards_name)
		skynet.name(leaderboards_name, lb)

		local channel = skynet.newservice("channel", game)
		skynet.name(".channel", channel)

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
