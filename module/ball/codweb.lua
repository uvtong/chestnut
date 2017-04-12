local skynet = require "skynet"
require "skynet.manager"
local mc = require "multicast"
local log = require "log"

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
	local game = skynet.uniqueservice("game")
	skynet.call(game, "lua", "start")
	table.insert(servers, game)

	local chat = skynet.uniqueservice("chatd")
	skynet.call(chat, "lua", "start")
	table.insert(servers, chat)
	
	local handle = skynet.uniqueservice("sid_mgr")
	skynet.call(handle, "lua", "start")
	table.insert(servers, handle)

	skynet.uniqueservice("agent_mgr")
	skynet.call(".AGENT_MGR", "lua", "start", 2)
	table.insert(servers, ".AGENT_MGR")

	-- skynet.newservice("branch")
	-- skynet.newservice("channel")
	skynet.uniqueservice("uid_mgr")
	skynet.call(".UID_MGR", "lua", "start")
	table.insert(servers, ".UID_MGR")

	skynet.uniqueservice("ai_mgr")
	skynet.call(".AI_MGR", "lua", "start")
	table.insert(servers, ".AI_MGR")

	local handle = skynet.uniqueservice("room_mgr")
	skynet.call(handle, "lua", "start")
	table.insert(servers, handle)

	local match = skynet.newservice("match")
	skynet.call(match, "lua", "start")
	table.insert(servers, match)

	local udpmgr = skynet.newservice("udpserver_mgr")
	skynet.call(udpmgr, "lua", "start")
	table.insert(servers, udpmgr)

	-- add 
	local signupd = skynet.getenv("signupd")
	if signupd  then
		local addr = skynet.newservice("signupd")
		local signupd_name = skynet.getenv("signupd_name")
		skynet.name(signupd_name, addr)
	end

	local logind = skynet.getenv("logind")
	if logind then
		local logind_name = skynet.getenv("logind_name")
		local addr = skynet.newservice("logind/logind")
		skynet.name(logind_name, addr)
	end     

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
	return true
end

function CMD.kill( ... )
	-- body
	for i,v in ipairs(servers) do
		-- print(v)
		-- print(skynet.queryservice(v))
		-- log.info(skynet.queryservice(false, v))
		skynet.call(v, "lua", "close")
	end
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
