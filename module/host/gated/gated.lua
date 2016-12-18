package.path = "./../../module/host/gated/?.lua;" .. package.path
local skynet = require "skynet"
local msgserver = require "snax.msgserver"
local crypt = require "crypt"
local netpack = require "netpack"
local log = require "log"


local loginservice = ".LOGIND"
local servername


local server = {}
local users = {}
local username_map = {}
local internal_id = 0
local forwarding  = {}	-- agent -> connection

-- login server disallow multi login, so login_handler never be reentry
-- call by login server
function server.login_handler(source, uid, secret, ...)
	if users[uid] then
		error(string.format("%s is already login", uid))
	end

	-- internal_id = internal_id + 1
	-- local id = internal_id	-- don't use internal_id directly
	local id = skynet.call(".SID_MGR", "lua", "login", uid)
	local username = msgserver.username(uid, id, servername)
	print(uid, id, servername, username)

	-- you can use a pool to alloc new agent
	-- local agent = skynet.newservice "agent"
	local agent = skynet.call(".AGENT_MGR", "lua", "enter", uid)
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
function server.forward_handler(source, uid, agent, ... )
	-- body
	local u = users[uid]
	if u then
		u.agent = agent
	end
end

-- call by agent
function server.unforward_handler(source, uid, ... )
	-- body
	-- msgserver.unforward
	local u = users[uid]
	if u then
		u.agent = nil
	end
end

-- call by self (when socket disconnect)
function server.disconnect_handler(username, fd)
	local u = username_map[username]
	if u then
		skynet.call(u.agent, "lua", "afk", fd)
	end
end

-- call by self
function server.start_handler(username, fd, version, idx, ... )
	-- body
	local u = username_map[username]
	if u then
		local agent = u.agent
		if agent then
			skynet.error("agent:", agent, idx)
			local conf = {
				gate = skynet.self(),
				client = fd,
				version = version,
				index = idx,
				uid = u.uid,
			}
			local ok = skynet.call(agent, "lua", "authed", conf)
			assert(ok)
		end
	end
end

function server.msg_handler(username, msg, sz,... )
	-- body
	local u = username_map[username]
	if u then
		local agent = u.agent
		if agent then
			skynet.redirect(agent, skynet.self(), "client", 0, msg, sz)
		else
			skynet.send(agent, "lua", "start", netpack.tostring(msg, sz))
		end
	end
end

-- call by self (when recv a request from client)
function server.request_handler(username, msg)

	-- local u = username_map[username]
	-- return skynet.unpack(skynet.rawcall(u.agent, "client", msg))
end

-- call by self (when gate open)
function server.register_handler(name)
	skynet.error(string.format("reister gate server: %s", name))
	servername = name
	local gated = skynet.getenv "gated"
	skynet.call(loginservice, "lua", "register_gate", servername, skynet.self(), gated)
end

msgserver.start(server)

