package.path = "./../logind/?.lua;" .. package.path
local login = require "snax.loginserver"
local crypt = require "crypt"
local skynet = require "skynet"
local accountmgr = require "models/accountmgr"
local db

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
	if accountmgr:get_by_user(user) == nil then
		local sql = string.format("select * from account where user = \"%s\" and password = \"%s\"", user, password)
		local r = skynet.call(".signup_db", "lua", "command", "query", sql)
		if #r >= 1 then
			error("has account")
		end
		-- for k,v in pairs(r) do
		-- 	print(k,v)
		-- end
		local sql = string.format("select * from uid where csv_id = 1")
		local r = skynet.call(".signup_db", "lua", "command", "query", sql)
		local csv_id = r[1].entropy
		sql = string.format("update uid set entropy=%d where csv_id=1", csv_id+1)
		skynet.call(".signup_db", "lua", "command", "query", sql)
		local tmp = {
			csv_id = csv_id,
			user=user, 
			password=password, 
			signuptime=os.time()
		}
		local u = accountmgr.create(tmp)
		accountmgr:add(u)
		u:__insert_db(1)
		return server, csv_id
	else
		error("no account")
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
	local r = skynet.call(".signup_db", "lua", "command", "query", sql)
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
