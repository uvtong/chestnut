local skynet = require "skynet"
require "skynet.manager"
local mc = require "multicast"
local log = require "log"

local servers = {}

local CMD = {}

function CMD.start( ... )
	-- body
	repeat 
		local conf = {
			db_host = skynet.getenv("db_host") or "192.168.1.116",
			db_port = skynet.getenv("db_port") or 3306,
			db_database = skynet.getenv("db_database") or "user",
			db_user = skynet.getenv("db_user") or "root",
			db_password = skynet.getenv("db_password") or "yulei",
		}
		
		local addr = skynet.newservice("db", "master")
		assert(skynet.call(addr, "lua", "start", conf))
		table.insert(servers, addr)
	until true
		
	local web = skynet.newservice("web/simpleweb")
	table.insert(servers, web)
	
	return true
end

function CMD.kill( ... )
	-- body
	for i,v in ipairs(servers) do
		if type(v) == "number" then
			log.info("call %s close", skynet.address(v))
		else
			log.info("call %s close", v)
		end	
		skynet.call(v, "lua", "close")
	end
	-- skynet.exit()
	skynet.abort()
end

function CMD.register(addr, ... )
	-- body
	table.insert(servers, addr)
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
