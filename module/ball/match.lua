local skynet = require "skynet"
local queue = require "queue"

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
	else
		local u = {
			uid = uid,
			agent = agent,
			online = true,
			logout = false
		}
		users[uid] = u
	end
	q:enqueue(u)
	if #q >= 1 then
		local u = q:dequeue()
		local room = skynet.call(".ROOM_MGR", "lua", "enter")
		local gate = skynet.call(".UDPSERVER_MGR", "lua", "enter")
	end
end

function cmd.apply(roomid)
	local room = rooms[roomid]
	if room == nil then
		gate_idx = gate_idx + 1 % gate_max
		local gate = udpgates[gate_idx]
		local r = snax.newservice("room", roomid, gate.udpgate.handle)
		room = {}
		room.gate = gate
		room.r = r
		rooms[roomid] = room
		return r.handle, gate.host, gate.port
	else
		return room.r.handle, room.gate.host, room.gate.port
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