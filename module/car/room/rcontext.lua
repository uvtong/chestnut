local skynet = require "skynet"
local gs = require "room.gamestate"
local region_mgr = require "room.region_mgr"
local sd = require "sharedata"
local log = require "log"
local list = require "list"
local player = require "player"

local type = {}
type.NONE  = 0
type.CIRCLE = 1

local cls = class("context", context)

cls.type = type

function cls:ctor(id, ... )
	-- body
	self._id = id
	self._gate = nil
	self._max_number = 8
	self._ballid = 1
	self._session_players = {}
	self._players_sz = 0
	-- self._buff_mgr = buff_mgr.new(self)
	self._region_mgr = nil
	self._state = gs.NONE
	self._type = type.NONE
	self._times = {}
	self._list = list.new()
	for i=1,30 do
		local tmp = player.new()
		list.add(self._list, tmp)
	end
end

function cls:get_buff_mgr( ... )
	-- body
	return self._buff_mgr
end

function cls:get_id( ... )
	-- body
	return self._id
end

function cls:set_gate(v, ... )
	-- body
	self._gate = v	
end

function cls:get_gate( ... )
	-- body
	return self._gate
end

function cls:add(uid, player, ... )
	-- body
	self._session_players[uid] = player
	self._players_sz = self._players_sz + 1
end

function cls:remove(uid, ... )
	-- body
	local player = self._session_players[uid]
	list.add(self._list, player)
	self._session_players[uid] = nil
	self._players_sz = self._players_sz - 1
end

function cls:get_player(uid, ... )
	-- body
	return self._session_players[uid]
end

function cls:get_players( ... )
	-- body
	return self._session_players
end

function cls:update(delta, k, ... )
	-- body
end

function cls:is_maxnum( ... )
	-- body
	return (self._players_sz >= self._max_number)
end

function cls:start(type, ... )
	-- body
	self._state = gs.STATE
	self._type = type
	self._region_mgr = region_mgr.new(self, self._id)
end

function cls:close( ... )
	-- body
	self._state = gs.CLOSE
	if self._type == type.CIRCLE then
		self:start(self._type)
	end
end

function cls:get_state( ... )
	-- body
	return self._state
end

function cls:set_state(value, ... )
	-- body
	self._state = value
end

function cls:get_freeplayer( ... )
	-- body
	return list.pop(self._list)
end

return cls