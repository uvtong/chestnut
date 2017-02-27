local skynet = require "skynet"
require "skynet.manager"
local log = require "log"

skynet.start(function()
	local logger = skynet.uniqueservice("log")
	skynet.call(logger, "lua", "start")
	
	-- local console = skynet.newservice("console")
	-- skynet.newservice("debug_console",8000)

	-- local codweb = skynet.uniqueservice("codweb")
	-- skynet.call(codweb, "lua", "start")
	
	-- log.info("host successful .")
	local conf = {
		db_host = skynet.getenv("db_host") or "192.168.1.116",
		db_port = skynet.getenv("db_port") or 3306,
		db_database = skynet.getenv("db_database") or "user",
		db_user = skynet.getenv("db_user") or "root",
		db_password = skynet.getenv("db_password") or "yulei",
		cache_host = skynet.getenv("cache_host") or "192.168.1.116",
		cache_port = skynet.getenv("cache_port") or 6379
	}
	
	local addr = skynet.newservice("db", "master")
	assert(skynet.call(addr, "lua", "start", conf))

	local w = skynet.newservice("watcher")
	skynet.call(w, "lua", "start")

	skynet.exit()
end)
