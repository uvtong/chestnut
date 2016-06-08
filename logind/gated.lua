-- local msgserver = require "snax.msgserver"
package.path = "./../logind/?.lua;" .. package.path
local skynet = require "skynet"
local pro_dir = skynet.getenv("pro_dir")
package.path = pro_dir.."?.lua;"..package.path
local msgserver = require "msgserver"
local crypt = require "crypt"
local skynet = require "skynet"

local loginservice = skynet.getenv("logind_name")

local servername
local gated

local server = {}
local users = {}
local username_map = {}
local internal_id = 0

-- login server disallow multi login, so login_handler never be reentry
-- call by login server
function server.login_handler(uid, secret, cmd, ...)
	if users[uid] then
		error(string.format("%s is already login", uid))
	end

	internal_id = internal_id + 1
	local id = internal_id	-- don't use internal_id directly
	local username = msgserver.username(uid, id, servername)
	print(uid, id, servername)

	-- you can use a pool to alloc new agent
	-- local agent = skynet.newservice "agent"
	local agent = skynet.call(".agent_mgr", "lua", "next")

	local u = {
		username = username,
		agent = agent,
		uid = uid,
		subid = id,
	}

	-- trash subid (no used)
	local ok = skynet.call(agent, "lua", cmd, uid, id, secret, game, db)
	assert(ok)
	print("###############################################2")
	
	users[uid] = u
	username_map[username] = u

	msgserver.login(username, secret)

	-- you should return unique subid
	return id, skynet.getenv("gated")
end

-- call by agent
function server.logout_handler(uid, subid)
	local u = users[uid]
	if u then
		local username = msgserver.username(uid, subid, servername)
		assert(u.username == username)
		msgserver.logout(u.username)
		users[uid] = nil
		username_map[u.username] = nil
		skynet.call(loginservice, "lua", "logout",uid, subid)
	end
end

-- call by login server
function server.kick_handler(uid, subid)
	local u = users[uid]
	if u then
		local username = msgserver.username(uid, subid, servername)
		assert(u.username == username)
		-- NOTICE: logout may call skynet.exit, so you should use pcall.
		pcall(skynet.call, u.agent, "lua", "logout")
	end
end

-- call by self (when socket disconnect)
function server.disconnect_handler(username)
	local u = username_map[username]
	if u then
		skynet.call(u.agent, "lua", "afk")
	end
end

-- call by self (when recv a request from client)
function server.request_handler(username, msg)
	local u = username_map[username]
	return skynet.unpack(skynet.rawcall(u.agent, "client", msg))
end

-- call by self (when gate open)
function server.register_handler(name)
	print("***************register_handler")
	servername = name
	skynet.call(loginservice, "lua", "register_gate", servername, skynet.self())
end

function server.send_request_handler(uid, subid, message)
	-- body
	local u = users[uid]
	assert(u.subid == subid)
	if u then
		local username = msgserver.username(uid, id, servername)
		assert(u.username == username)
		local ok, result = pcall(msgserver.send_request, u.username, message)
		if not ok then
			skynet.error(result)
		end
	end
end

function server.response_handler(username, msg)
	-- body
	local u = username_map[username]
	skynet.send(u.agent, "client", msg)
end

msgserver.start(server)

