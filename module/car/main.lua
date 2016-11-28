package.cpath = "./../../module/ball/luaclib/?.so;"..package.cpath
local skynet = require "skynet"
require "skynet.manager"
local snax = require "snax"
local log = require "log"
local sd = require "sharedata"

skynet.start(function()
	local logger = skynet.uniqueservice("log")
	skynet.call(logger, "lua", "start")
	
	skynet.newservice("codweb")
	
	skynet.uniqueservice("protoloader")
	
	local console = skynet.newservice("console")
	skynet.newservice("debug_console",8000)
	
	-- read
		
	-- local lb = skynet.newservice("leaderboards", "ara_leaderboards")
	-- skynet.name(".LB", lb)
	
	skynet.newservice("agent_mgr")
	skynet.call(".AGENT_MGR", "lua", "start", 1)
	skynet.newservice("ai_mgr")
	skynet.call(".AI_MGR", "lua", "start")
	-- skynet.newservice("branch")
	-- skynet.newservice("channel")
	local keeper = snax.uniqueservice("roomkeeper")
	keeper.req.start()

	repeat
		local conf = {
			db_host = skynet.getenv("db_host") or "192.168.1.116",
			db_port = skynet.getenv("db_port") or 3306,
			db_database = "ball",
			db_user = skynet.getenv("db_user") or "root",
			db_password = skynet.getenv("db_password") or "yulei",
			cache_host = skynet.getenv("cache_host") or "192.168skynet.newservice("ai_mgr")
	skynet.call(".AI_MGR", "lua", "start").1.116",
			cache_port = skynet.getenv("cache_port") or 6379
		}
		local addr = skynet.newservice("db")
		assert(skynet.call(addr, "lua", "start", conf))
		skynet.name(".SIGNUPD_DB", addr)
	until true
	
	local signupd = skynet.getenv("signupd")
	if signupd  then
		local addr = skynet.newservice("signupd")
		local signupd_name = skynet.getenv("signupd_name")
		skynet.name(signupd_name, addr)
	end

	repeat 
		local conf = {
			db_host = skynet.getenv("db_host") or "192.168.1.116",
			db_port = skynet.getenv("db_port") or 3306,
			db_database = "ball",
			db_user = skynet.getenv("db_user") or "root",
			db_password = skynet.getenv("db_password") or "yulei",
			cache_host = skynet.getenv("cache_host") or "192.168.1.116",
			cache_port = skynet.getenv("cache_port") or 6379
		}

		local db = skynet.newservice("db")
		skynet.name(".LOGIND_DB", db)
		assert(skynet.call(db, "lua", "start", conf))
	until true

	local logind = skynet.getenv("logind")
	if logind then
		local logind_name = skynet.getenv("logind_name")
		local addr = skynet.newservice("logind/logind")
		skynet.name(logind_name, addr)
	end     

	repeat 
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
	until true

	local gated = skynet.getenv("gated")
	if gated then
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

	local game = skynet.uniqueservice("game")
	skynet.call(game, "lua", "start")
	
	log.info("car host successful .")
	
	skynet.exit()
end)