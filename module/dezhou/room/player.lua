local skynet = require "skynet"
local card = require "card"
local group = require "group"
local log = require "log"

local state = {}
state.NONE       = 0
state.ENTER      = 1
state.WAIT_START = 2
state.READY      = 3
state.DEAL       = 4
state.DEALED     = 5
state.WAIT_ROB   = 6
state.ROBED      = 7
state.WAIT_OROB  = 8
state.WAIT_CI    = 9
state.CI         = 10
state.WAIT_ALEAD = 11
state.WAIT_PLEAD = 12
state.WAIT_OLEAD = 13
state.CLOSE      = 14

local cls = class("player")

cls.state = state

function cls:ctor(env, uid, sid, fd, ... )
	-- body
	assert(env)
	self._env    = env
	self._uid    = uid
	self._sid    = sid
	self._agent  = fd  -- agent
	self._idx    = 0      -- players index
	self._online = false  -- user in game
	self._robot  = false  -- user
	self._noone  = true
	self._name   = ""
	self._chip   = 0

	self._state  = state.NONE
	self._cards  = {}

	self._bet    = 0

	return self
end

function cls:get_uid( ... )
	-- body
	return self._uid
end

function cls:set_uid(value, ... )
	-- body
	self._uid = value
end

function cls:get_sid( ... )
	-- body
	return self._sid
end

function cls:set_sid(value, ... )
	-- body
	self._sid = value
end

function cls:set_agent(agent, ... )
	-- body
	self._agent = agent
end

function cls:get_agent( ... )
	-- body
	return self._agent
end

function cls:get_idx( ... )
	-- body
	return self._idx
end

function cls:set_online(value, ... )
	-- body
	self._online = value
end

function cls:get_online( ... )
	-- body
	return self._online
end

function cls:set_robot(flag, ... )
	-- body
	self._robot = flag
end

function cls:get_robot( ... )
	-- body
	return self._robot
end

function cls:set_name(name, ... )
	-- body
	self._name = name
end

function cls:get_name( ... )
	-- body
	return self._name
end

function cls:get_chip( ... )
	-- body
	return self._chip
end

function cls:set_chip(value) 
	self._chip = value
end

function cls:set_state(s, ... )
	-- body
	self._state = s
end

function cls:get_state( ... )
	-- body
	return self._state
end

function cls:get_cards( ... )
	-- body
	return self._cards
end

function cls:get_cards_value( ... )
	-- body
	local cards = {}
	for i,card in ipairs(self._cards) do
		local v = card:get_value()
		cards[i] = v
	end
	return cards
end

function cls:clear_cards( ... )
	-- body
	self._cards = {}
end

function cls:deal(card, ... )
	-- body
	local idx = #self._cards
	if idx <= 2 then
		idx = idx + 1
		self._cards[idx] = card
	end
end

function cls:start( ... )
	-- body
	self._state = state.NONE
	self._cards = {}
end

function cls:close( ... )
	-- body
end




return cls