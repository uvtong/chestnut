local skynet = require "skynet"
require "skynet.manager"
local "room_mgr" = require "room_mgr"
local noret = {}
local mgr
local users = {}

local function init( ... )
	-- body
	local arr = {}
	local rule = 1
	local mode = 1
	local scene = 1
	local rt = (scene << 24 | mode << 16 | rule << 8)
	table.insert(arr, rt)
	mgr = room_mgr.new(arr)
end

local CMD = {}

function CMD.enqueue_agent(source, uid, rule, mode, scene, ... )
	-- body
	local agent = {
		agent = source,
		uid = uid,
		rt = rt,
		rule = rule,
		mode = mode,
		scene = scene,
	}
	users[uid] = agent

	local rt = (scene << 24 | mode << 16 | rule << 8)
	mgr:enqueue_agent(rt, agent)
	if mgr:get_queue_sz(rt) >= 3 then
		local room = mgr:dequeue_room()
		skynet.call(room, "lua", "start", rt)
		local agents = {}
		for i=1,3 do
			local agent = dequeue_agent(q)
			users[agent.uid] = nil
			table.insert(agents, agent)
		end
		skynet.call(room, "lua", "enter_room", agents)
	end
	return noret
end

function CMD.dequeue_agent(source, uid, ... )
	-- body
	local agent = users[uid]
	if agent then
		users[uid] = nil
		mgr:del_agent(agent)
	end
end

-- room exit
function CMD.enqueue_room(source, room, ... )
	-- body
	mgr:enqueue_room(room)
	return noret
end

function CMD.start(source, ... )
	-- body
	init()
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