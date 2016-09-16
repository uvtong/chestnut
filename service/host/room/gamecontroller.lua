local player = require "player"
local controller = require "controller"
local group = require "group"
local gs = require "gamestate"
local assert = assert

local cls = class("gamecontroller", controller)

function cls:ctor(env, name, ... )
	-- body
	assert(env and name)
	cls.super.ctor(self, env, name)
	
	self._ready_count = 0

	self._first_rob_player = false
	self._dz_player = false
	self._deal_dz_cards = {}
	self._dz_cards = {}
	
	self._deal_player = false
	self._state = gs.CLOSE
end

function cls:get_type( ... )
	-- body
	return self._type
end

function cls:update(delta, ... )
	-- body
	-- self._myplayer:update(delta)
	-- self._rightplayer:update(delta)
	-- self._leftplayer:update(delta)
end

function cls:start(t, ... )
	-- body
	-- assert(false)
	-- assert(t)
	-- self._type = t
	-- if self._type == gt.SINGLE then
	-- 	self._state = gs.START
	-- 	self._first_rob_player = false
	-- 	self._dz_player = false
	-- 	self._deal_player = false
	-- 	self._dizhu_cards = {}

	-- 	self._myplayer:start(gt.SINGLE)
	-- 	self._rightplayer:start(gt.SINGLE)
	-- 	self._leftplayer:start(gt.SINGLE)

	-- 	self._scene:start(self._myplayer, self._rightplayer, self._leftplayer)
	-- 	self._env:push(self._scene)
	-- elseif self._type == gt.NETWORK then
	-- 	self._state = gs.START
	-- 	self._scene:start(self._myplayer, self._rightplayer, self._leftplayer)
	-- 	self._env:push(self._scene)
	-- else
	-- 	assert(false)
	-- end
end

function cls:close( ... )
	-- body
end

-- 
function cls:start_game( ... )
	-- body
	self._ready_count = 0
	self._state = gs.START
	self._first_rob_player = false
	self._dz_player = false
	self._deal_player = false
	self._dizhu_cards = {}

end

function cls:ready(player, flag, ... )
	-- body
	assert(player)
	player:set_ready(flag)
	self._ready_count = self._deal_player + 1
	if self._ready_count == 3 then
		-- self:confirm_readiness()
		self:deal_cards_starting(player)
	end
end

function cls:confirm_readiness(player, ... )
	-- body
	self:deal_cards_starting()
end

-- 发牌七个函数
function cls:deal_cards_starting(player, ... )
	-- body
	assert(player)
	self:deal_cards(player)
end

function cls:deal_cards(player, ... )
	-- body
	assert(player)
	self._env:shuffle()
	self._deal_player = player
	self:deal()
end

function cls:take_turn_to_deal(last, ... )
	-- body
	assert(last)
	local next = assert(last:get_next())
	self._deal_player = next
	self:deal()
end

function cls:deal( ... )
	-- body
	if self._env:rest_of_deal() > 3 then
		local card = self._env:next_card()
		self._deal_player:deal(card)
	else
		if self._env:rest_of_deal() > 0 then
			local card = self._env:next_card()
			self:insert_card(self._dz_cards, card)
			self:deal_dz_cb(card)
		else
			-- self:rob_starting()

		end
	end
end

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

function cls:deal_dz_cb(c, ... )
	-- body
	assert(c)
	self:deal()
end

function cls:send_request_deal( ... )
	-- body
	local cards = {}
	for i,card in ipairs(self._deal_dz_cards) do
		local v = card:get_value()
		table.insert(cards, v)
	end
	local players = self._env:get_players()
	for i=1,3 do
		local player = players[i]
		player:send_request_deal(cards)
	end
end

-- 开始抢地主
function cls:rob_starting( ... )
	-- body
	if self._type == gt.SINGLE then
		self._state = gs.ROB
		local rand = 1
		if rand == 1 then
			self._first_rob_player = self._myplayer
			self._myplayer:ready_for_rob()
		end
	elseif self._type == gt.NETWORK then
	else
		assert(false)
	end
end

function cls:take_turn_to_rob(last)
	assert(last)
	if self._myplayer == last then
		self._rightplayer:ready_for_rob()
	elseif self._rightplayer == last then
		self._leftplayer:ready_for_rob()
	elseif self._leftplayer == last then
		self._myplayer:ready_for_rob()
	else
		assert(false)
	end
end

-- 判断谁是地主
function cls:confirm_identity( ... )
	-- body
	if self._first_rob_player == self._myplayer then
		local rob = self._myplayer:get_rob()
		assert(#rob == 2)
		if rob[2] then
			self._myplayer:set_dizhu(true)
			self._dz_player = self._myplayer
		else
			local rob = self._leftplayer:get_rob()
			assert(#rob == 1)
			if rob[1] then
				self._leftplayer:set_dizhu(true)
				self._dz_player = self._leftplayer
			else
				self._rightplayer:set_dizhu(true)
				self._dz_player = self._rightplayer
			end
		end
	elseif self._first_rob_player == self._leftplayer then
		local rob = self._leftplayer:get_rob()
		assert(#rob == 2)
		if rob[2] then
			self._leftplayer:set_dizhu(true)
			self._dz_player = self._leftplayer
		else
		end
	elseif self._first_rob_player == self._rightplayer then
		local rob = self._rightplayer:get_rob()
		assert(#rob == 2)
		if rob[2] then
			self._rightplayer:set_dizhu(true)
			self._dz_player = self._rightplayer
		else
			local rob = self._myplayer:get_rob()
			assert(#rob == 1)
			if rob[1] then
				self._myplayer:set_dizhu(true)
				self._dz_player = self._myplayer
			else
			end
		end
	else
		assert(false)
	end
	self:lead_starting(self._dz_player)
end

-- 开始出牌
function cls:lead_starting( ... )
	-- body
	local player = self._dz_player
	player:ready_for_alead()
end

function cls:take_turn_to_lead(last, g, ... )
	-- body
	assert(last and g)
	if self._myplayer == last then
		if g and g:get_kind() ~= group.kind.NONE then
			self._rightplayer:ready_for_plead(g)
		end
	elseif self._rightplayer == last then
		if g and g:get_kind() ~= group.kind.NONE then
			self._leftplayer:ready_for_plead(g)
		end
	elseif self._leftplayer == last then
		if g and g:get_kind() ~= group.kind.NONE then
			self._myplayer:ready_for_plead(g)
		end
	end
end

return cls