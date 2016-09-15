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
	self._myplayer = myplayer.new(self._env, self, scene)
	self._rightplayer = rightplayer.new(self._env, self, scene)
	self._leftplayer = leftplayer.new(self._env, self, scene)
	self._first_rob_player = false
	self._dz_player = false
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
	self._myplayer:update(delta)
	self._rightplayer:update(delta)
	self._leftplayer:update(delta)
end

function cls:start(t, ... )
	-- body
	assert(t)
	self._type = t
	if self._type == gt.SINGLE then
		self._state = gs.START
		self._first_rob_player = false
		self._dz_player = false
		self._deal_player = false
		self._dizhu_cards = {}

		self._myplayer:start(gt.SINGLE)
		self._rightplayer:start(gt.SINGLE)
		self._leftplayer:start(gt.SINGLE)

		self._scene:start(self._myplayer, self._rightplayer, self._leftplayer)
		self._env:push(self._scene)
	elseif self._type == gt.NETWORK then
		self._state = gs.START
		self._scene:start(self._myplayer, self._rightplayer, self._leftplayer)
		self._env:push(self._scene)
	else
		assert(false)
	end
end

function cls:close( ... )
	-- body
end

function cls:onBack( ... )
	-- body
	if self._state == gs.CLOSE then
		self._env:pop()
	else
		assert(false)
	end
end

function cls:start_game( ... )
	-- body
	if self._type == gt.SINGLE then
		self._state = gs.START
		self._first_rob_player = false
		self._dz_player = false
		self._deal_player = false
		self._dizhu_cards = {}
	elseif self._type == gt.NETWORK then
	else
		assert(false)
	end
end

function cls:confirm_readiness( ... )
	-- body
	local player = self._myplayer
	self:deal_cards_starting()
end

-- 发牌七个函数
function cls:deal_cards_starting( ... )
	-- body
	local player = self._myplayer
	self:deal_cards(player)
end

function cls:deal_cards(player, ... )
	-- body
	assert(player)
	self._env:shuffle()
	self._scene:show_a_cards()
	self._deal_player = player
	self:deal()
end

function cls:take_turn_to_deal(last, ... )
	-- body
	assert(last)
	if last	== self._myplayer then
		self._deal_player = self._rightplayer
	elseif last == self._rightplayer then
		self._deal_player = self._leftplayer
	elseif last == self._leftplayer then
		self._deal_player = self._myplayer
	else
		assert(false)
	end
	self:deal()
end

function cls:deal( ... )
	-- body
	if self._env:rest_of_deal() > 3 then
		local card = self._env:next_card()
		if self._deal_player == self._myplayer then
			self._myplayer:deal(card)
		elseif self._deal_player == self._rightplayer then
			self._rightplayer:deal(card)
		elseif self._deal_player == self._leftplayer then
			self._leftplayer:deal(card)
		else
			assert(false)
		end
	else
		if self._env:rest_of_deal() > 0 then
			local card = self._env:next_card()
			self:insert_card(self._dz_cards, card)
			self._scene:deal(self, card)
		else
			self:rob_starting()
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

function cls:deal_move(card, ... )
	-- body
	assert(card)
	local spc = cc.p(900, 1210)
	local delta = cc.p(30, 0)
	local cards = {}
	local callback = handler(self, cls.deal_dz_cb)
	assert(callback)
	local idx = card:get_idx()
	local len = #self._dz_cards
	if idx < len then
		for i=idx+1,len do
			table.insert(cards, self._dz_cards[i])
		end
		self._scene:move_cards(cards, callback, spc, delta)
	else
		self._scene:move_cards(cards, callback, spc, delta)
	end
end

function cls:deal_dz_cb(v, ... )
	-- body
	self._dizhu_cards[v] = v
	self:deal()
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

function cls:c2s_enter_room_req( ... )
	-- body
end

function cls:c2s_enter_room_rsp( ... )
	-- body
end

function cls:s2c_enter_room_req( ... )
	-- body
end

function cls:s2c_enter_room_rsp( ... )
	-- body
end

return cls