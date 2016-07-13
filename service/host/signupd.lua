package.path = "./../logind/?.lua;../lualib/?.lua;" .. package.path
local login = require "snax.loginserver"
local crypt = require "crypt"
local skynet = require "skynet"
local accountmgr = require "models/accountmgr"
local query = require "query"
local db
local MAX_INTEGER = 16777216

local address, port = string.match(skynet.getenv("signupd"), "([%d.]+)%:(%d+)")
local server = {
	host = address or "127.0.0.1",
	port = port or 8001,
	multilogin = false,	-- disallow multilogin
	name = "signup_master",
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
	-- judge is exits
	print("####################################33")
	local sql = string.format("select * from account where user = \"%s\"", user)
	local r = query.read(".signup_db", "account", sql)

	if #r >= 1 then
		error("has account")
	else
		local sql = string.format("select * from uid where id = %d", 1)
		local r = query.read(".signup_db", "uid", sql)
		assert(#r == 1)
		id = r[1].entropy + 1
		sql = string.format("update uid set entropy = %d where id = %d", id, 1)
		query.write(".signup_db", "uid", sql)
		sql = string.format("insert into account (`id`, `user`, `password`, `signuptime`, `csv_id`) values ( %d, \"%s\", \"%s\", %d, %d)", id, user, password, os.time(), id)
		query.write(".signup_db", "account", sql)
		--skynet.send(".signup_db", "lua", "command", "insert_sql", "account", sql, 1)
		return server, id
	end
end

function server.login_handler(server, uid, secret)
	print(string.format("%s@%s is login, secret is %s", uid, server, crypt.hexencode(secret)))
	-- local gameserver = assert(server_list[server], "Unknown server")
	-- -- only one can login, because disallow multilogin
	-- local last = user_online[uid]
	-- if last then
	-- 	skynet.call(last.address, "lua", "kick", uid, last.subid)
	-- end
	-- if user_online[uid] then
	-- 	error(string.format("user %s is already online", uid))
	-- end

	-- local subid = tostring(skynet.call(gameserver, "lua", "login", uid, secret))
	-- user_online[uid] = { address = gameserver, subid = subid , server = server}
	-- return subid
	return uid
end

local CMD = {}

function CMD.register_gate(server, address)
	server_list[server] = address
end

function CMD.auth(user, password)
	-- body
	local sql = string.format("select * from account where user = \"%s\" and password = \"%s\"", user, password)
	local r = query.read(".signup_db", "account", sql)
	if #r ~= 1 then
		print("account system has error.")
		return false, "error"
	else
		return true, r[1].csv_id
	end
end

function server.command_handler(command, ...)
	local f = assert(CMD[command])
	return f(...)
end

login(server)
