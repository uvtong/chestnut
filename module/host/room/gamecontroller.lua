local skynet = require "skynet"
local player = require "player"
local controller = require "controller"
local group = require "group"
local gs = require "gamestate"
local errorcode = require "errorcode"
local assert = assert

local cls = class("gamecontroller", controller)

function cls:ctor(env, name, ... )
	-- body
	assert(env and name)
	cls.super.ctor(self, env, name)
	
	self._mrule = nil
	self._mode = nil
	self._mscene = nil

	self._state = gs.CLOSE

	self._first_rob_player = nil
	self._deal_player = nil
	self._dz_cards = {}

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

function cls:set_state(v, ... )
	-- body
	self._state = v
end

function cls:get_rule( ... )
	-- body
	return self._mrule
end

function cls:set_rule(v, ... )
	-- body
	self._mrule = v	
end

function cls:set_mode(v, ... )
	-- body
	self._mode = v
end

function cls:get_mode( ... )
	-- body
	return self._mode
end

function cls:set_scene(v, ... )
	-- body
	self._mscene = v
end

function cls:get_scene( ... )
	-- body
	return self._mscene
end

function cls:start(t, ... )
	-- body
	self._state = gs.START

	self._deal_player = nil
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

function cls:confirm_readiness( ... )
	-- body
	local players = self._env:get_players()
	if players[1]:get_state() == player.state.READY and
		players[2]:get_state() == player.state.READY and
		players[3]:get_state() == player.state.READY then
		local r = math.random(1, 3)
		self._first_rob_player = players[r]
		-- self:deal_cards_starting(self._first_rob_player)
		return true
	else
		return false
	end
end

-- 发牌七个函数
function cls:deal_cards_starting( ... )
	-- body
	local players = self._env:get_players()
	for i=1,3 do
		players[i]:ready_for_deal()
	end
	self:deal_cards(self._first_rob_player)
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
		-- c:set_z(idx)
		c:set_master(cards)
		return c
	else
		local idx = #cards
		for i=idx,1,-1 do
			local o = cards[i]
			if c:mt_t(o) then
				cards[i + 1] = o
				o:set_idx(i + 1)
				-- o:set_z(i + 1)
				assert(o:get_master() == cards)
			else
				cards[i + 1] = c
				c:set_idx(i + 1)
				-- c:set_z(i + 1)
				c:set_master(cards)
				return c
			end
		end
		-- 只有一种情况
		cards[1] = c
		c:set_idx(1)
		-- c:set_z(1)
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
function cls:confirm_identity(last, ... )
	-- body
	assert(last == self._first_rob_player)
	local rob = self._first_rob_player:get_rob()
	assert(#rob == 2)
	if rob[2] then
		player:set_dz(true)
		self._dz_player = player
	else
		local player = self._first_rob_player:get_last()
		local rob = player:get_rob()
		assert(#rob == 1)
		if rob[1] then
			player:set_dz(true)
			self._dz_player = player
		else
			local player = player:get_last()
			local rob = player:get_rob()
			assert(#rob == 1)
			player:set_dz(true)
			self._dz_player = player
		end
	end
	assert(self._dz_player)
	self:lead_starting()
end

-- 开始出牌
function cls:lead_starting( ... )
	-- body
	self._dz_player:ready_for_alead()
end

function cls:take_turn_to_lead(last, g, ... )
	-- body
	assert(last and g)
	local n = last:get_next()
	n:ready_for_plead(g)
	self._deal_player = n
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

-- game protocol
function cls:on_ready(player, flag, ... )
	-- body
	assert(player)
	if flag then
		local res = {}
		player:set_state(player.state.READY)
		if self:confirm_readiness() then
			self:deal_cards_starting()
			res.errorcode = errorcode.SUCCESS
			res.sid = player:get_sid()
			res.ready = flag
			res.deal = true
			res.cards = self._env:get_pack_cards()
			res.your_turn = self._first_rob_player:get_uid()
			res.countdown = 10
		else
			res.errorcode = errorcode.SUCCESS
			res.sid = player:get_sid()
			res.ready = flag
			res.deal = false
		end
		local last = player:get_last()
		if last:get_online() then
			skynet.send(last:get_agent(), "lua", "ready", res)
		end
		local next = player:get_next()
		if next:get_online() then
			skynet.send(next:get_agent(), "lua", "ready", res)
		end
		return res
	else
		log.error("player %d ready is false", player:get_uid())
	end
end

function cls:on_rob(player, args, ... )
	-- body
	assert(self._state == gs.ROB)
	assert(self._rob_player == player)
	
	player:rob((args.rob > 0 and true or false))

	local res = {}
	res.errorcode = errorcode.SUCCESS
	res.sid = player:get_sid()
	res.rob = args.rob
	if self._dz_player then
		res.confirm = true
		res.dz = self._dz_player:get_sid()
	else
		res.confirm = false
		res.your_turn = _rob_player:get_sid()
		res.countdown = 10
	end
	local l = player:get_last()
	if l then
		skynet.send(l:get_agent(), "lua", "rob", res)
	end
	local n = player:get_next()
	if n then
		skynet.send(next:get_agent(), "lua", "rob", res)
	end
	return res
end

function cls:on_lead(player, flag, cards, ... )
	-- body
	assert(self._state == gs.LEAD)
	player:lead(cards)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	res.sid = player:get_sid()
	res.cards = cards
	if self._state == gs.CLOSE then
		res.turn = false
		res.settlement = true
		res.ranked1 = {sid=players[1]:get_sid()}
		res.ranked2 = {sid=players[2]:get_sid()}
		res.ranked3 = {sid=players[3]:get_sid()}
	else
		res.turn = true
		res.your_turn = self._lead_player:get_sid()
		res.countdown = 10
		res.settlement = false
	end
	local l = player:get_last()
	if l then
		skynet.send(l:get_agent(), "lua", "lead", res)
	end
	local n = player:get_next()
	if n then
		skynet.send(n:get_agent(), "lua", "lead", res)
	end
	return res
end

function cls:on_dealed(p, args, ... )
	-- body
	p:set_state(player.state.WAIT_ROB)
	local players = self._env:get_players()
	if players[1]:get_state() == player.state.WAIT_ROB and
		players[2]:get_state() == player.state.WAIT_ROB and
		players[3]:get_state() == player.state.WAIT_ROB then
		-- self._rob_player = self._first_rob_player
		args.rob = true
		args.your_turn = self._first_rob_player:get_sid()
		args.countdown = 10
	else
	end
	local l = p:get_last()
	if l then
		skynet.send(l:get_agent(), "lua", "dealed", args)
	end
	local n = p:get_next()
	if n then
		skynet.send(n:get_agent(), "lua", "dealed", args)
	end
	args.errorcode = errorcode.SUCCESS
	return args
end

return cls