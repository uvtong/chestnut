local skynet = require "skynet"
require "skynet.manager"
local log = require "log"

skynet.start(function()
	local logger = skynet.uniqueservice("log")
	skynet.call(logger, "lua", "start")
	
	skynet.newservice("codweb")
	
	skynet.uniqueservice("protoloader")
	
	local console = skynet.newservice("console")
	-- skynet.newservice("debug_console",8000)
	
	-- read
	local game = skynet.uniqueservice("game")
	skynet.name(".game", game)
		
	-- local lb = skynet.newservice("leaderboards", "ara_leaderboards")
	-- skynet.name(".LB", lb)
	
	skynet.newservice("agent_mgr")
	skynet.newservice("branch")
	-- skynet.newservice("channel")
	
	
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
		local addr = skynet.newservice("db")
		assert(skynet.call(addr, "lua", "start", conf))
		skynet.name(".SIGNUPD_DB", addr)
		
		local addr = skynet.newservice("signupd")
		local signupd_name = skynet.getenv("signupd_name")
		skynet.name(signupd_name, addr)
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

		local db = skynet.newservice("db")
		skynet.name(".logind_db", db)
		assert(skynet.call(db, "lua", "start", conf))
		
		-- local addr = skynet.newservice("logind/logindata")
		-- skynet.name(".logindata", addr)
		
		local logind_name = skynet.getenv("logind_name")
		local addr = skynet.newservice("logind/logind")
		skynet.name(logind_name, addr)
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
		
		local addr = skynet.newservice("db")
		skynet.name(".DB", addr)
		assert(skynet.call(addr, "lua", "start", conf))
		

		local logind_name = skynet.getenv("logind_name")
		local server_name = skynet.getenv("gated_name")
		local max_client = skynet.getenv("maxclient")
		local address, port = string.match(skynet.getenv("gated"), "([%d.]+)%:(%d+)")
		local gated = skynet.newservice("gated/gated")
		skynet.name(".GATED", gated)
		skynet.call(gated, "lua", "open", { 
			address = address or "0.0.0.0",
			port = port,
			maxclient = tonumber(max_client),
			servername = server_name,
			--nodelay = true,
		})
	end

	log.INFO("host successful .")
	
	skynet.exit()
end)
