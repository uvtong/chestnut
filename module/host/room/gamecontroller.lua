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
	
	self._state = gs.CLOSE
	self._ready_count = 0

	-- cur deal player
	self._deal_player = nil
	self._deal_dz_cards = {}
	self._dz_cards = {}

	self._first_rob_player = nil
	self._rob_player = nil

	self._dz_player = nil
	
	self._lead_player = nil
end

function cls:update(delta, ... )
	-- body
	-- self._myplayer:update(delta)
	-- self._rightplayer:update(delta)
	-- self._leftplayer:update(delta)
end

function cls:get_state( ... )
	-- body
	return self._state
end

function cls:start(t, ... )
	-- body
	self._state = gs.START

	self._ready_count = 0

	self._deal_player = nil
	self._deal_dz_cards = {}
	self._dizhu_cards = {}

	self._first_rob_player = nil
	self._rob_player = nil

	self._dz_player = nil

	self._lead_player = nil

	local players = self._env:get_players()
	for i,player in ipairs(players) do
		player:start()
	end
end

function cls:close( ... )
	-- body
end

function cls:confirm_readiness(player, ... )
	-- body
	local players = self:players()
	if players[1]:get_state() == player.state.READY and
		players[2]:get_state() == player.state.READY and
		players[3]:get_state() == player.state.READY then
		local r = math.random(1, 3)
		if r == 1 then
			self._first_rob_player = self._myplayer
		elseif r == 2 then
			self._first_rob_player = self._rightplayer
		elseif r == 3 then
			self._first_rob_player = self._leftplayer
		end
		local p = self._first_rob_player
		self:deal_cards_starting(p)
		return true
	else
		return false
	end
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

function cls:deal_dz_cb(c, ... )
	-- body
	assert(c)
	self:deal()
end

-- 开始抢地主
function cls:rob_starting( ... )
	-- body
	self._state = gs.ROB
	self._first_rob_player:ready_for_rob()
	self._rob_player = self._first_rob_player
end

function cls:take_turn_to_rob(last)
	assert(last)
	local next = assert(last:get_next())
	next:ready_for_rob()
	self._rob_player = next
end

-- 判断谁是地主
function cls:confirm_identity( ... )
	-- body
	local player = assert(self._first_rob_player)
	local rob = self._myplayer:get_rob()
	assert(#rob == 2)
	if rob[2] then
		player:set_dz(true)
		self._dz_player = player
	else
		local player = player:get_next()
		local rob = player:get_rob()
		assert(#rob == 1)
		if rob[1] then
			player:set_dz(true)
			self._dz_player = player
		else
			local player = player:get_next()
			local rob = player:get_rob()
			assert(#rob == 1)
			player:set_dz(true)
			self._dz_player = player
		end
	end
	local players = self._env:get_players()
	for i=1,3 do
		local player = players[i]
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

function cls:confirm_over(player, ... )
	-- body
	local cards = player:get_cards()
	if #cards == 0 then
		self._state = gs.CLOSE
		-- self._scene
		return true
	else
		return false
	end
end

function cls:ready(player, flag, ... )
	-- body
	assert(player)
	if flag then
		local res = {}
		player:set_state(player.state.READY)
		if self:confirm_readiness() then
			self:deal_cards_starting(self._first_rob_player)
			res.uid = player:get_uid()
			res.ready = flag
			res.errorcode = errorcode.SUCCESS
			res.deal = true
			res.cards = self:get_pack_cards()
			res.your_turn = self._first_rob_player:get_uid()
			res.countdown = 10

			return res
		else
			res.uid = player:get_uid()
			res.ready = flag
			res.errorcode = errorcode.SUCCESS
			res.deal = false
		end
		local last = player:get_last()
		skynet.send(last:get_agent(), "lua", "ready", res)
		local next = player:get_next()
		skynet.send(next:get_agent(), "lua", "ready", res)
		return res
	else
		log.error("player %d ready is false", player:get_uid())
	end
end

function cls:rob(player, flag, ... )
	-- body
	assert(self._dz_player == nil)
	assert(self._state == gs.ROB)
	assert(self._rob_player == player)
	assert(type(flag) == "number")
	flag = flag > 0 and true or false
	player:rob(flag)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	res.uid = player:get_uid()
	res.rob = flag
	if self._dz_player then
		res.confirm = true
		res.dz = self._dz_player:get_uid()
	else
		res.confirm = false
		res.your_turn = player:get_next():get_uid()
		res.countdown = 10
	end
	local last = player:get_last()
	skynet.send(last:get_agent(), "lua", "rob", res)
	local next = player:get_next()
	skynet.send(next:get_agent(), "lua", "rob", res)
	return res
end

function cls:lead(player, flag, cards, ... )
	-- body
	assert(self._state == gs.LEAD)
	if flag then

	else
	end
end

return cls