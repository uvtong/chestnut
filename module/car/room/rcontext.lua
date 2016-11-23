local skynet = require "skynet"
local skynet_queue = require "skynet.queue"
local sd = require "sharedata"
local log = require "log"
local list = require "list"
local gs = require "room.gamestate"
local region_mgr = require "room.region_mgr"
local food_mgr = require "room.food_mgr"
local player = require "room.player"

local type = {}
type.NONE  = 0
type.CIRCLE = 1

local cls = class("context")

cls.type = type

function cls:ctor(id, ... )
	-- body
	self._id = id
	self._gate = nil
	self._max_number = 8
	self._number = 0
	
	self._session_players = {}
	self._players_sz = 0
	self._player_cs = skynet_queue()

	self._ais = {}
	self._ai_sz = 0
	self._aics = skynet_queue()
	
	self._state = gs.NONE
	self._type = type.NONE
	self._times = {}

	self._list = list.new()
	for i=1,35 do
		local tmp = player.new()
		list.add(self._list, tmp)
	end
	self._csfree = skynet_queue()

	self._region_mgr = nil
	self._food_mgr = food_mgr.new(self, self._id)
end

function cls:get_buff_mgr( ... )
	-- body
	return self._buff_mgr
end

function cls:get_food_mgr( ... )
	-- body
	return self._food_mgr
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
	local function func( ... )
		-- body
		self._number = self._number + 1
		self._players_sz = self._players_sz + 1
	end
	self._player_cs(func)
end

function cls:remove(uid, ... )
	-- body
	local player = self._session_players[uid]
	assert(player)
	self._session_players[uid] = nil
	local function func( ... )
		-- body
		self._number = self._number + 1
		self._players_sz = self._players_sz - 1
	end
	self._player_cs(func)
	local function func( ... )
		-- body
		list.add(self._list, player)
	end
	self._csfree(func)
end

function cls:get_player(uid, ... )
	-- body
	local player = self._session_players[uid]
	if player then
		return player
	else

		log.error("uid: %d, player is no existen", uid)
	end
end

function cls:get_players( ... )
	-- body
	return self._session_players
end

function cls:add_ai(id, player, ... )
	-- body
	assert(id and player)
	self._ais[id] = player
	local function func( ... )
		-- body
		self._number = self._number + 1
		self._ai_sz = self._ai_sz + 1
	end
	self._aics(func)
end

function cls:remove_ai(id, ... )
	-- body
	assert(id)
	local player = assert(self._ais[id])
	self._ais[id] = nil
	local function func( ... )
		-- body
		self._number = self._number - 1
		self._ai_sz = self._ai_sz - 1
	end
	self._aics(func)
	local function func( ... )
		-- body
		list.add(self._list, player)
	end
	self._csfree(func)
end

function cls:get_ai(id, ... )
	-- body
	return self._ais[id]
end

function cls:get_ais( ... )
	-- body
	return self._ais
end

function cls:get_num( ... )
	-- body
	return self._number
end

function cls:get_maxnum( ... )
	-- body
	return self._max_number
end

function cls:start(type, ... )
	-- body
	self._state = gs.STATE
	self._type = type
	self._region_mgr = region_mgr.new(self, self._id)
	self._food_mgr:start()
end

function cls:close( ... )
	-- body
	self._state = gs.CLOSE
	if self._type == type.CIRCLE then
		self:start(self._type)
	else
		local gate = ctx:get_gate()
		gate.req.unregister(session)
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
	local function func( ... )
		-- body
		return list.pop(self._list)
	end
	return self._csfree(func)
end

return cls