local skynet = require "skynet"
local context = require "context"

local cls = class("context")

function cls:ctor(id, ... )
	-- body
	self._id = id
	self._aoi = nil
	self._battle = nil
	self._gate = nil
	self._map = nil
	self._view = nil
	self._scene = nil
	self._max_number = 8
	self._sub_players = {}
	self._sub_players_sz = 0
	self._uplayers = {}
	self._uplayers_sz = 0
	self._players = {}
	self._players_sz = 0

	self._stime = nil
end

function cls:set_aoi(v, ... )
	-- body
	self._aoi = v
end

function cls:get_aoi( ... )
	-- body
	return self._aoi
end

function cls:get_battle( ... )
	-- body
	return self._battle
end

function cls:set_battle(v, ... )
	-- body
	self._battle = v
end

function cls:set_gate(v, ... )
	-- body
	self._gate = v	
end

function cls:get_gate( ... )
	-- body
	return self._gate
end

function cls:set_map(v, ... )
	-- body
	self._map = v
end

function cls:get_map( ... )
	-- body
	return self._map
end

function cls:set_view(v, ... )
	-- body
	self._view = v
end

function cls:get_view( ... )
	-- body
	return self._view
end

function cls:set_scene(v, ... )
	-- body
	self._scene = v
end

function cls:get_scene( ... )
	-- body
	return self._scene
end

function cls:addsp(session, player, ... )
	-- body
	self._splayers[session] = player
	self._splayers_sz = self._splayers_sz + 1
end

function cls:remove(session, ... )
	-- body
	assert(session)
	if self._splayers[session] then
		self._splayers[session] = nil
		self._splayers_sz = self._splayers_sz -1
	end
end

function cls:getsp(session, ... )
	-- body
	return self._splayers[session]
end

function cls:getsp_sz( ... )
	-- body
	return self._splayers_sz
end

function cls:addup(uid, player, ... )
	-- body
	self._uplayers[uid] = player
	self._uplayers_sz = self._uplayers_sz + 1
end

function cls:removeup(uid, ... )
	-- body
	assert(uid)
	if self._uplayers[uid] then
		self._uplayers[uid] = nil
		self._uplayers_sz = self._uplayers_sz + 1
	end
end

function cls:getup(uid, ... )
	-- body
	return self._uplayers[uid]
end

function cls:getup_sz( ... )
	-- body
	return self._uplayers_sz
end

function cls:update(delta, k, ... )
	-- body
	self._scene:move(delta)
	skynet.send(self._aoi, "lua", "message")

	local t2 = skynet.now()
	local data = string.pack("<III", t2, 0, 0)
	local ball_data = self._scene:pack_balls()
	local protocol = 2
	for session,v in pairs(self._session_players) do
		data = data .. string.pack("<III", session, protocol, k) .. ball_data
		self._gate.post.post(session, data)
	end
end

function cls:broadcast_die(args, ... )
	-- body
	for k,v in pairs(self._session_players) do
		local agent = v:get_agent()
		agent.post.die(args)
	end
end

function cls:is_maxnum( ... )
	-- body
	return (self._players_sz >= self._max_number)
end

function cls:set_stime(v, ... )
	-- body
	self._stime = v
end

function cls:get_stime( ... )
	-- body
	return self._stime
end

function cls:start(gate, max, mapid, ... )
	-- body
	self._gate = gate
	self._max_number = max
	-- load map id

	return true
end

function cls:close( ... )
	-- body
	for _,user in pairs(users) do
		gate.req.unregister(user.session)
	end
	return true
end

function cls:push_client(name, args, ... )
	-- body

end

return cls