local skynet = require "skynet"
require "skynet.manager"
local room_queue = require "room_queue"
local noret = {}
local users = {}
local mgr

local CMD = {}

function CMD.enqueue_agent(source, uid, sid, rule, mode, scene, ... )
	-- body
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
	if mgr:get_queue_sz(rt) > 1 then
		local room = mgr:dequeue_room()
		skynet.call(room, "lua", "start", rule, mode, scene)
		if true then
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

function CMD.apply(roomid, ... )
	-- body
	return mgr:get_use_room().room
end

-- room exit
function CMD.enqueue_room(source, room, ... )
	-- body
	enqueue_room(room)
	return noret
end

function CMD.start(source, ... )
	-- body
	local rt = (scene << 24 | mode << 16 | rule << 8)
	local arr = { rt}
	local mgr = room_queue.new(false, arr)
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
	skynet.register ".ROOM_MGR"
end)