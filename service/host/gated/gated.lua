package.path = "./../../service/host/logind/?.lua;" .. package.path
local msgserver = require "msgserver"
local crypt = require "crypt"
local log = require "log"


local loginservice = ".LOGIND"
local servername


local server = {}
local users = {}
local username_map = {}
local internal_id = 0

-- login server disallow multi login, so login_handler never be reentry
-- call by login server
function server.login_handler(source, uid, secret, ...)
	if users[uid] then
		error(string.format("%s is already login", uid))
	end

	internal_id = internal_id + 1
	local id = internal_id	-- don't use internal_id directly
	local username = msgserver.username(uid, id, servername)
	print(uid, id, servername)

	-- you can use a pool to alloc new agent
	-- local agent = skynet.newservice "agent"
	local agent = skynet.call(".AGENT_MGR", "lua", "enter")

	local u = {
		username = username,
		agent = agent,
		uid = uid,
		subid = id,
	}

	-- trash subid (no used)
	local ok = skynet.call(agent, "lua", "login", uid, id, secret)
	assert(ok)
	
	users[uid] = u
	username_map[username] = u

	msgserver.login(username, secret)

	-- you should return unique subid
	return id
end

-- call by agent
function server.logout_handler(source, uid, subid)
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
function server.kick_handler(source, uid, subid)
	local u = users[uid]
	if u then
		local username = msgserver.username(uid, subid, servername)
		assert(u.username == username)
		-- NOTICE: logout may call skynet.exit, so you should use pcall.
		pcall(skynet.call, u.agent, "lua", "logout")
	end
end

-- call by agent
function server.forward(source, ... )
	-- body
end

-- call by agent

function server.unforward(source, ... )
	-- body
	msgserver.unforward
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

msgserver.start(server)

