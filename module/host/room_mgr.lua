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
end


function CMD.kill( ... )
	-- body
	skynet.exit()
end

function CMD.enqueue_agent(source, uid, rule, mode, scene, ... )
	-- body
	log.info("enqueue_agent")
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

	local rt = (scene << 24 | mode << 16 | rule << 8)
	mgr:enqueue_agent(rt, agent)
	if mgr:get_agent_queue_sz(rt) >= 1 then
		local room = mgr:dequeue_room()
		if true then
			room.t = rt
			room.num =  3
			mgr:add_full(rt, room)
			mgr:add_use(room)
			skynet.call(room.room, "lua", "start", rule, mode, scene, 2)
			for i=1,1 do
				local agent = mgr:dequeue_agent(rt)
				users[agent.uid] = nil
				skynet.send(agent.agent, "lua", "enter_room", room.id)
			end
		else
			for i=1,3 do
				local agent = mgr:dequeue_agent(rt)
				users[agent.uid] = nil
				skynet.send(agent.agent, "lua", "enter_room", room.id)
			end	
		end
	end
	return noret
end

function CMD.dequeue_agent(source, uid, ... )
	-- body
	if users[uid] then
		users[uid] = nil
		local q = rt_room_queue[agent.rt]
		del_agent(q, agent)
	end
end

function CMD.apply(source, roomid, ... )
	-- body
	local room = mgr:get_use(roomid)
	return room.room
end

-- room exit
function CMD.enqueue_room(source, roomid, ... )
	-- body
	local room = mgr:get_use(roomid)
	if room.num == 3 then
		mgr:remove_fule(room.t, room)
		mgr:remove_use(room)
		mgr:enqueue_room(room)
	else
		assert(false)
	end
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