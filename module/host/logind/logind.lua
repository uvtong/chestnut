package.path = "./../../module/host/logind/?.lua;"..package.path
local skynet = require "skynet"
local login = require "loginserver"
local crypt = require "crypt"
local log = require "log"


local address, port = string.match(skynet.getenv("logind"), "([%d.]+)%:(%d+)")
local server = {
	host = address or "127.0.0.1",
	port = tonumber(port) or 8002,
	multilogin = false,	-- disallow multilogin
	name = ".LOGIND",
	instance = 8,
}

local server_list = {}
local user_online = {}
local user_login = {}

function server.auth_handler(token)
	-- the token is base64(user)@base64(server):base64(password)
	local user, server, password = token:match("([^@]+)@([^:]+):(.+)")
	user = crypt.base64decode(user)
	server = crypt.base64decode(server)
	password = crypt.base64decode(password)
	-- assert(password == "password", "Invalid password")
	local ok, userid = skynet.call(".SIGNUPD", "lua", "auth", user, password)
	if ok then
		return server, uid
	else
		error(uid)
		return server, 0
	end
end

function server.login_handler(server, uid, secret)
	print(string.format("%s@%s is login, secret is %s", uid, server, crypt.hexencode(secret)))
	local gameserver = assert(server_list[server], "Unknown server")
	-- only one can login, because disallow multilogin
	local last = user_online[uid]
	if last then
		skynet.call(last.address, "lua", "kick", uid, last.subid)
	end
	if user_online[uid] then
		error(string.format("user %s is already online", uid))
	end
	print("gameserver is called", gameserver.address)
	
	local subid = skynet.call(gameserver.address, "lua", "login", uid, secret)
	user_online[uid] = { address = gameserver.address, subid = subid , server = server}
	local gated = gameserver.gated
	log.info("gated: %s", gated)

	return subid, gated
end

local CMD = {}

function CMD.register_gate(server, address, gated)
	server_list[server] = {}
	server_list[server].address = address
	server_list[server].gated = gated
end

function CMD.logout(uid, subid)
	local u = user_online[uid]
	if u then
		print(string.format("%s@%s is logout", uid, u.server))
		user_online[uid] = nil
	end
end

function server.command_handler(command, ...)
	local f = assert(CMD[command])
	return f(...)
end

login(server)
