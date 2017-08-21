local skynet = require "skynet"
require "skynet.manager"
local log = require "skynet.log"
local queue = require "queue"


local m1q = queue()
local m2q = queue()
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

function cmd.enter(uid, agent, mode, ... )
	-- body
	assert(uid and agent and mode)
	local u = users[uid]
	if u then
		u.online = true
		if u.agent ~= agent then
			u.agent = agent
		end
		if u.inq then
			return 1 -- 
		end
	else
		u = {
			uid = uid,
			agent = agent,
			online = true,
			mode = mode,
		}
		users[uid] = u
		
	end

	if u.inq then
		log.info("uid :%d in queue", uid)
		return
	end
	if mode == 1 then
		m1q:enqueue(u)
		u.inq = true
	elseif mode == 2 then
		m2q:enqueue(u)
		u.inq = true
	end

	-- check num of person
	if mode == 1 then
		log.info("mode 1")
		if #m1q >= 1 then
			local u = m1q:dequeue()
			u.inq = false
			local id = skynet.call(".ROOM_MGR", "lua", "enter")
			local addr = skynet.call(".ROOM_MGR", "lua", "apply", id)
			local gate = skynet.call(".UDPSERVER_MGR", "lua", "enter")
			skynet.call(addr, "lua", "start", gate, 10)
			skynet.send(u.agent, "lua", "match", {roomid=id})
		else
			log.info("length of m1q is: %d", #m1q)
		end
	elseif mode == 2 then
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