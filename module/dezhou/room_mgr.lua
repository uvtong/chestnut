package.path = "./../../module/host/lualib/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local waiting_queue = require "waiting_queue"
local log = require "log"
local noret = {}
local users = {}
local mgr

local CMD = {}

function CMD.start(source, ... )
	-- body
	return true
end

function CMD.close( ... )
	-- body
	return true
end

function CMD.kill( ... )
	-- body
	skynet.exit()
end

function CMD.afk(source, uid, ... )
	-- body
	assert(uid)
	local u = users[uid]
	if u then
		mgr:remove_agent(u)
		users[uid] = nil
	end
end

function CMD.enqueue_agent(source, uid, rule, mode, scene, ... )
	-- body
	log.info("enqueue_agent")
	local rt = ((scene & 0xff << 16) | (mode & 0xff << 8) | (rule & 0xff))
	local agent = {
		agent = source,
		uid = uid,
		sid = sid,
		rt = rt,
		rule = rule,
		mode = mode,
		scene = scene,
	}
	users[uid] = agent
	mgr:enqueue_agent(rt, agent)

	if mgr:get_agent_queue_sz(rt) >= 3 then
		log.info("room number more than 3")
		local room = mgr:dequeue_room()
		for i=1,3 do
			local u = mgr:dequeue_agent(rt)
			skynet.send(u.agent, "lua", "enter_room", room.id)
			users[u.uid] = nil
		end	
	end
	return noret
end

function CMD.dequeue_agent(source, uid, ... )
	-- body
	assert(uid)
	local u = users[uid]
	if u then
		mgr:remove_agent(u)
		users[uid] = nil
	end
end

function CMD.apply(source, roomid, ... )
	-- body
	local room = mgr:get(roomid)
	return room.addr
end

-- room exit
function CMD.enqueue_room(source, roomid, ... )
	-- body
	local room = mgr:get(roomid)
	mgr:remove(room)
	mgr:enqueue_room(room)
	return noret
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function (_, source, cmd, ... )
		-- body
		local f = assert(CMD[cmd])
		local r = f(source, ...)
		if r ~= noret then
			skynet.retpack(r)
		end
	end)
	local rt = ( 1 << 24 | 1 << 16 | 1 << 8)
	local arr = { rt}
	mgr = waiting_queue.new(false, arr)
	skynet.register ".ROOM_MGR"
end)