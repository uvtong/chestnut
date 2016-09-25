local card = require "card"
local group = require "group"

local state = {}
state.NONE = 0
state.WAIT_START = 1
state.READY = 2
state.WAIT_ROB = 3
state.WAIT_OROB = 4
state.WAIT_FAPAI = 5
state.WAIT_ALEAD = 6
state.WAIT_PLEAD = 7
state.WAIT_OLEAD = 8
state.CLOSE = 9

local cls = class("player")

function cls:ctor(env, uid, fd, ... )
	-- body
	assert(env and uid and fd)
	self._env = env
	self._uid = uid
	self._agent = fd  -- agent
	self._last = false
	self._next = false
	self._idx  = -1    -- players in
	self._ready = false
	self._rob = {}
	self._is_dz = false
	self._deal_cards = {}
	self._cards = {}
	return self
end

function cls:set_uid(uid, ... )
	-- body
	self._uid = uid
end

function cls:get_uid( ... )
	-- body
	return self._uid
end

function cls:set_agent(agent, ... )
	-- body
	self._agent = agent
end

function cls:get_agent( ... )
	-- body
	return self._agent
end

function cls:set_last(player, ... )
	-- body
	self._last = player
end

function cls:get_last( ... )
	-- body
	return self._last
end

function cls:set_next(player, ... )
	-- body
	self._next = player
end

function cls:get_next( ... )
	-- body
	return self._next
end

function cls:set_idx(idx, ... )
	-- body
	self._idx = idx
end

function cls:get_idx( ... )
	-- body
	return self._idx
end

function cls:set_ready(flag, ... )
	-- body
	assert(flag)
	self._ready = flag

	-- TODO

end

function cls:get_ready( ... )
	-- body
	return self._ready
end

function cls:set_rob(flag, ... )
	-- body
	local sz = #self._rob
	if sz == 2 then
		return false
	else
		sz = sz	+ 1
		self._rob[sz] = flag
	end
end

function cls:get_rob( ... )
	-- body
	return self._rob
end

-- deal 3 function.
function cls:insert_card(cards, c, ... )
	-- body
	assert(cards and c)
	assert(c:get_master() == false, c:get_master())
	if #cards == 0 then
		local idx = 1
		table.insert(cards, c)
		c:set_idx(idx)
		c:set_z(idx)
		c:set_master(cards)
		return c
	else
		local idx = #cards
		for i=idx,1,-1 do
			local o = cards[i]
			if c:mt_t(o) then
				cards[i + 1] = o
				o:set_idx(i + 1)
				o:set_z(i + 1)
				assert(o:get_master() == cards)
			else
				cards[i + 1] = c
				c:set_idx(i + 1)
				c:set_z(i + 1)
				c:set_master(cards)
				return c
			end
		end
		-- 只有一种情况
		cards[1] = c
		c:set_idx(1)
		c:set_z(1)
		c:set_master(cards)
		return c
	end
end

function cls:deal(c, ... )
	-- body
	assert(c)
	table.insert(self._deal_cards, c)
	self:insert_card(self._cards, c)
	self:deal_cb(c)
end

function cls:deal_cb(c)
	-- body
	assert(c)
	local controller = self._env:get_controller("game")
	controller:take_turn_to_deal(self)
end

function cls:send_request_deal(dz_cards, ... )
	local cards = {}
	for i,card in ipairs(self._deal_cards) do
		local v = card:get_value()
		table.insert(cards, v)
	end
	local args = {}
	args.dz_cards = dz_cards
	args.cards = cards
	local agent = self._agent
	skynet.send(agent, "lua", "send_request", "deal", args)
end

function cls:ready_for_rob( ... )
	-- body
	self._state = state.WAIT_ROB
	local idx = #self._rob
	if idx == 0 then
		idx = idx + 1
		self._rob[idx] = false
		-- client
		-- local cd = 10 * 100
		-- local function complet( ... )
		-- 	-- body
		-- 	if self._state == state.WAIT_ROB then
		-- 		local sz = #self._rob
		-- 		if sz == 1 then
		-- 			self:rob(false)
		-- 		end
		-- 	end
		-- end
		-- skynet.timeout(cd, complet)
	elseif idx == 1 then
		idx = idx + 1
		self._rob[idx] = false
	end
end

function cls:rob(flag, ... )
	-- body
	assert(type(flag) == "boolean")
	assert(self._state == state.WAIT_ROB)
	self._state = state.WAIT_OROB
	local idx = #self._rob
	self._rob[idx] = flag
	if idx == 1 then
		local controller = self._env:get_controller("game")
		controller:take_turn_to_rob(self)
	elseif idx == 2 then
		local controller = self._env:get_controller("game")
		controller:confirm_identity()
	end
end

function cls:is_dz( ... )
	-- body
	return self._is_dz
end

function cls:set_dz(flag, ... )
	-- body
	self._is_dz = flag
end

function cls:lead(cards, ... )
	-- body
end

function cls:is_over( ... )
	-- body
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

return cls