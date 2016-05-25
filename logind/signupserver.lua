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
	local sql = string.format("select * from account where user = \"%s\"", user)
	local r = query.read(".signup_db", "account", sql)
	-- local r = skynet.call(".signup_db", "lua", "command", "query", sql)
	if #r >= 1 then
		error("has account")
	else
		local backup = {}
		local id
		local function gen_id()
			-- body
			local rand = math.random(1, 4)
			if backup[rand] then
				return false
			end
			local sql = string.format("select * from uid where id = %d", rand)
			local r = skynet.call(".signup_db", "lua", "command", "query", sql)	
			assert(#r == 1)
			id = r.entropy
			if id < MAX_INTEGER then
				sql = string.format("update uid set entropy = %d where id = %d", id + 1, rand)
				skynet.send(".signup_db", "lua", "command", "update_sql", "uid", sql, 1)		
				id = id << 8
				rand = rand & 255
				id = id | rand
				return true
			else		
				backup[rand] = true
				return false
			end
		end
		while gen_id() do
		end
		sql = string.format("insert into account (id, user, password, signuptime) values ( %d, \"%s\", \"%s\", %d)", id, user, password, os.time())
		skynet.send(".signup_db", "lua", "command", "insert_sql", "account", sql, 1)
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
