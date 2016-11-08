local skynet = require "skynet"
local cls = class("context")

function cls:ctor(id, ... )
	-- body
	self._id = id
	self._aoi = nil
	self._gate = nil
	self._map = nil
	self._view = nil
	self._scene = nil
	self._max_number = 8
	self._ballid = 1
	self._session_players = {}
	self._players_sz = 0
end

function cls:set_aoi(v, ... )
	-- body
	self._aoi = v
end

function cls:get_aoi( ... )
	-- body
	return self._aoi
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

function cls:gen_ball_id( ... )
	-- body
	self._ballid = self._ballid + 1
	if self._ballid <= 0 then
		self._ballid = 1 
	end
	return self._ballid
end

function cls:add(session, player, ... )
	-- body
	self._session_players[session] = player
	self._players_sz = self._players_sz + 1
end

function cls:remove(session, ... )
	-- body
	self._session_players[_session_players] = nil
	self._players_sz = self._players_sz - 1
end

function cls:get(session, ... )
	-- body
	return self._session_players[session]
end

function cls:get_players( ... )
	-- body
	return self._session_players
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

return cls