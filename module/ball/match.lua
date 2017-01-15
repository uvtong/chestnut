local skynet = require "skynet"
require "skynet.manager"
local queue = require "queue"
local log = require "log"

local q = queue()
local users = {}

local cmd = {}

function cmd.start( ... )
	-- body
	return true
end

function cmd.close( ... )
	-- body
	return true
end

function cmd.kill( ... )
	-- body
	skynet.exit()
end

function cmd.afk(uid, ... )
	-- body
	local u = users[uid]
	if u then
		u.online = false
	end
end

function cmd.logout(uid, ... )
	-- body
	local u = users[uid]
	if u then
		u.logout = true
	end
end

function cmd.enter(uid, agent, ... )
	-- body
	local u = users[uid]
	if u then
		u.online = true
		u.logout = false
		log.info("uid:%d enter")
	else
		local u = {
			uid = uid,
			agent = agent,
			online = true,
			logout = false
		}
		users[uid] = u
		q:enqueue(u)
	end
	log.info("length of q: %d", #q)
	if #q >= 1 then

		local u = q:dequeue()
		users[u.uid] = nil

		local res = skynet.call(".ROOM_MGR", "lua", "enter")
		local gate = skynet.call(".UDPSERVER_MGR", "lua", "enter")
		skynet.call(res.addr, "lua", "start", gate)
		skynet.send(u.agent, "lua", "match", {roomid=res.id})
	end
end

function cmd.exchange(roomid, ... )
	-- body
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function(_,_, command, subcmd, ...)
		local f = cmd[command]
		local r = f(subcmd, ... )
		if r ~= nil then
			skynet.ret(skynet.pack(r))
		end
	end)
	skynet.register ".MATCH"
end)