package.path = "./../../service/logind/?.lua;"..package.path

local login = require "snax.loginserver"
local crypt = require "skynet.crypt"
local skynet = require "skynet"
local log = require "skynet.log"

local address, port = string.match(skynet.getenv("logind"), "([%d.]+)%:(%d+)")
local name = skynet.getenv "logind_name"
local server = {
	host = address or "127.0.0.1",
	port = tonumber(port) or 8002,
	multilogin = false,	-- disallow multilogin
	name = name,
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
	assert(password == "Password", "Invalid password")
	log.info("auth_handler %s@%s:%s", user, server, password)
	local res = skynet.call(".WX_SIGNUPD", "lua", "signup", server, user)
	if res.code == 200 then
		return server, res.uid
	else
		error("not authed")
	end
end

function server.login_handler(server, uid, secret)
	log.info(string.format("%s@%s is login, secret is %s", uid, server, crypt.hexencode(secret)))
	local gameserver = assert(server_list[server], "Unknown server")
	-- only one can login, because disallow multilogin
	local last = user_online[uid]
	if last then
		log.info("login_handler kick %d", last.address)
		skynet.call(last.address, "lua", "kick", uid, last.subid)
	else
		log.info("login_handler no kick")
	end
	if user_online[uid] then
		error(string.format("user %s is already online", uid))
	end
	
	local subid = skynet.call(gameserver.address, "lua", "login", uid, secret)
	if subid > 0 then
		user_online[uid] = { address = gameserver.address, subid = subid , server = server}
		local gated = gameserver.gated

		local res = string.format("%s#%d@%s", uid, subid, gated)
		-- local res = subid
		log.info("login res = %s", res)
		return res
	else
		error("subid is wrong")
	end
end

local CMD = {}

function CMD.register_gate(server, address, gated)
	local s = {
		address = address,
		gated = gated,
	}
	server_list[server] = s
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
