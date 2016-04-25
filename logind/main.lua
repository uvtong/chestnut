local skynet = require "skynet"
require "skynet.manager"
local sprotoloader = require "sprotoloader"

local max_client = 64
local server_name = "sample"
local logind_name = "login_master"

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
	
    server_name = skynet.getenv("servername")
    max_client = skynet.getenv("maxclient") or 64
    logind_name = skynet.getenv("logind_name") or logind_name
    local loginserver
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
		skynet.name(".signup_db", db)
		local ok = assert(skynet.call(db, "lua", "start", conf))
    	local address, port = string.match(skynet.getenv("signupd"), "([%d.]+)%:(%d+)")
		local signupserver = skynet.newservice("signupserver", db)
		skynet.name(".signupd", signupserver)

		loginserver = skynet.newservice("logind")
		skynet.name(logind_name, loginserver)
	else
		loginserver = skynet.queryservice(true, logind_name)
	end

	local game = skynet.newservice("game", db)
	local gated = skynet.newservice("gated", loginserver, game, db)
	address, port = string.match(skynet.getenv("gated"), "([%d.]+)%:(%d+)")
	skynet.call(gated, "lua", "open", { 
		port = 8888,
		maxclient = max_client,
		servername = server_name,
		--nodelay = true,
	})
	skynet.exit()
end)
