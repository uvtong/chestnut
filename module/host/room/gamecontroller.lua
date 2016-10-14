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
	self._rob_player = false
	self._dz_player = false
	self._deal_dz_cards = {}
	self._dz_cards = {}
	
	self._deal_player = false
	self._state = gs.CLOSE
end

function cls:update(delta, ... )
	-- body
	-- self._myplayer:update(delta)
	-- self._rightplayer:update(delta)
	-- self._leftplayer:update(delta)
end

function cls:start(t, ... )
	-- body
	self._ready_count = 0
	self._state = gs.START
	self._first_rob_player = false
	self._dz_player = false
	self._deal_player = false
	self._dizhu_cards = {}
end

function cls:close( ... )
	-- body
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
	local next = assert(last:get_next())
	next:ready_for_rob()
end

function cls:rob(player, flag, ... )
	-- body
	assert(self._state == gs.ROB)
	assert(player == self._rob_player)
	player:rob(flag)
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

function cls:on_ready(args, ... )
	local uid = args.uid
	local ready = args.ready
	local player = assert(self:get_player_by_uid(uid))
	if player:get_ready() then
		assert(false, "client send error message.")
	else
		self._ready_count = self._ready_count + 1
		player:set_ready(ready)
	end
	if self._ready_count >= 3 then
		self:deal_cards_starting(player)

		local dcards = {}
		for i,card in ipairs(self._dz_cards) do
			dcards[i] = card:get_value()
		end
		args.deal = true
		args.dcards = dcards
		args.your_turn = uid
		args.countdown = 10

		local last = assert(player:get_last())
		if last then
			local llast = assert(last:get_last())
			args.lcards = llast:get_cards_value()
			local lnext = assert(last:get_next())
			args.rcards = lnext:get_cards_value()
			local agent = last:get_agent()
			skynet.send(agent, "lua", "ready", args)
		end

		local next = assert(player:get_next())
		if next then
			local nlast = assert(next:get_last())
			args.lcards = nlast:get_cards_value()
			local nnext = assert(next:get_next())
			args.rcards = nnext:get_cards_value()
			local agent = next:get_next()
			skynet.send(agent, "lua", "ready", args)
		end

		local res = {}
		res.errorcode = errorcode.SUCCESS
		res.deal = true
		res.lcards = last:get_cards_value()
		res.rcards = next:get_cards_value()
		
		res.dcards = dcards
		res.your_turn = uid
		res.countdown = 10
		return res
	else
		args.deal = false
		local last = player:get_last()
		if last then
			local agent = last:get_agent()
			skynet.send(agent, "lua", "ready", args)
		end

		local next = player:get_next()
		if next then
			local agent = next:get_next()
			skynet.send(agent, "lua", "ready", args)
		end
		local res = {}
		res.errorcode = errorcode.SUCCESS
		res.deal = false
		return res
	end
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

function cls:on_rob(args, ... )
	-- body
end

function cls:rob( ... )
	-- body
end

function cls:on_lead(args, ... )
	-- body
end

function cls:lead(args, ... )
	-- body
end

return cls