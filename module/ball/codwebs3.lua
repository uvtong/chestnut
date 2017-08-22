local skynet = require "skynet"
require "skynet.manager"
local mc = require "skynet.multicast"
local log = require "skynet.log"

local servers = {}

local CMD = {}

function CMD.start( ... )
	-- body
	-- db
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
		
		local addr = skynet.newservice("db", "master")
		assert(skynet.call(addr, "lua", "start", conf))
		table.insert(servers, addr)
	until true

	-- read
	local dbmonitor = skynet.newservice("dbmonitord")
	skynet.call(dbmonitor, "lua", "start")
	table.insert(servers, dbmonitor)

	return true
end

function CMD.kill( ... )
	-- body
	for _,v in ipairs(servers) do
		-- print(v)
		-- print(skynet.queryservice(v))
		-- log.info(skynet.queryservice(false, v))
		skynet.call(v, "lua", "close")
	end
	-- for _,v in pairs(servers) do
	-- 	skynet.send(v, "lua", "kill")
	-- end
	-- skynet.exit()
	skynet.abort()
end

skynet.start( function () 
	skynet.dispatch("lua" , function( _, source, command, ... )
		local f = assert(CMD[command])
		local r = f(source, ...)
		if r then
			skynet.ret(skynet.pack(r))
		end
	end)
	skynet.register ".CODWEB"
end)
