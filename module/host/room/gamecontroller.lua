local skynet = require "skynet"
local player = require "player"
local controller = require "controller"
local group = require "group"
local gs = require "gamestate"
local errorcode = require "errorcode"
local log = require "log"
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
	self._dz_cards = {}
	self._dz_cards_deal_idx = 0

	self._first_rob_player = nil
	self._deal_player      = nil
	self._rob_player       = nil
	self._dz_player        = nil
	self._lead_player      = nil
	self._leadcount        = 0
end

function cls:update(delta, ... )
	-- body
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
	self._dz_cards = {}
	self._dz_cards_deal_idx = 0

	self._first_rob_player = nil
	self._deal_player      = nil
	self._rob_player       = nil
	self._dz_player        = nil
	self._lead_player      = nil

	local players = self._env:get_players()
	for i,player in ipairs(players) do
		player:start()
	end
end

function cls:close( ... )
	-- body
	self._state = gs.CLOSE
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

-- 发牌5个函数
function cls:deal_cards_starting( ... )
	-- body
	self._state = gs.DEAL
	self._env:shuffle()
	local players = self._env:get_players()
	for i=1,3 do
		players[i]:ready_for_deal()
	end
	self._deal_player = self._first_rob_player
	self:deal()
end

-- called by player
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
			local players = self._env:get_players()
			for i=1,3 do
				local p = players[i]
				p:ready_for_dealed()
			end
		end
	end
end

function cls:deal_dz_cb(c, ... )
	-- body
	assert(c)
	self:deal()
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

-- 开始抢地主
function cls:rob_starting( ... )
	-- body
	self._state = gs.ROB
	self._rob_player = self._first_rob_player
	self._rob_player:ready_for_rob()
end

-- called by player
function cls:take_turn_to_rob(last)
	assert(last)
	self._rob_player = assert(last:get_next())
	self._rob_player:ready_for_rob()
end

-- 判断谁是地主
function cls:confirm_identity(last, ... )
	-- body
	assert(last == self._first_rob_player)
	local rob = self._first_rob_player:get_rob()
	assert(#rob == 2)
	if rob[2] then
		self._first_rob_player:set_dz(true)
		self._dz_player = self._first_rob_player
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
	self._state = gs.CRDZ
	self:deal_dz_starting()
end

function cls:deal_dz_starting( ... )
	-- body
	self._dz_cards_deal_idx = 0
	self:take_turn_to_deal_dz()
end

function cls:take_turn_to_deal_dz( ... )
	-- body
	self._dz_cards_deal_idx = self._dz_cards_deal_idx + 1
	if self._dz_cards_deal_idx <= 3 then
		local card = self._dz_cards[self._dz_cards_deal_idx]
		card:set_idx(0)
		card:set_master(false)
		self._dz_player:deal_dz(card)
	end
end

function cls:confirm_identityed( ... )
	-- body
	local players = self._env:get_players()
	if players[1]:get_state() == player.state.CI and
		players[2]:get_state() == player.state.CI and
		players[3]:get_state() == player.state.CI then
		return true
	else
		return false
	end
end

-- 开始出牌
function cls:lead_starting( ... )
	-- body
	self._state = gs.LEAD
	self._lead_player = self._dz_player
	self._lead_player:ready_for_alead()
end

function cls:take_turn_to_lead(last, g, ... )
	-- body
	assert(last and g)
	self._lead_player = last:get_next()
	self._lead_player:ready_for_plead(g)
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
function cls:on_ready(p, flag, ... )
	-- body
	if flag then
		local res = {}
		p:set_state(player.state.READY)
		if self:confirm_readiness() then
			self:deal_cards_starting()
			res.errorcode = errorcode.SUCCESS
			res.sid = p:get_sid()
			res.ready = flag
			res.deal = true
			res.cards = self._env:get_pack_cards()
			res.your_turn = self._first_rob_player:get_sid()
			res.countdown = 10
		else
			res.errorcode = errorcode.SUCCESS
			res.sid = p:get_sid()
			res.ready = flag
			res.deal = false
		end
		local last = p:get_last()
		if not last:get_aiflag() and last:get_online() then
			skynet.send(last:get_agent(), "lua", "ready", res)
		end
		local next = p:get_next()
		if not next:get_aiflag() and next:get_online() then
			skynet.send(next:get_agent(), "lua", "ready", res)
		end
		return res
	else
		log.error("player %d ready is false", player:get_uid())
	end
end

function cls:on_dealed(p, args, ... )
	-- body
	p:set_state(player.state.WAIT_ROB)
	local players = self._env:get_players()
	if players[1]:get_state() == player.state.WAIT_ROB and
		players[2]:get_state() == player.state.WAIT_ROB and
		players[3]:get_state() == player.state.WAIT_ROB then
		self:rob_starting()
		args.rob = true
		args.your_turn = self._first_rob_player:get_sid()
		args.countdown = 10
	else
		args.rob = false
	end
	local l = p:get_last()
	if not l:get_aiflag() and l:get_online() then
		skynet.send(l:get_agent(), "lua", "dealed", args)
	end
	local n = p:get_next()
	if not n:get_aiflag() and n:get_online() then
		skynet.send(n:get_agent(), "lua", "dealed", args)
	end
	args.errorcode = errorcode.SUCCESS
	return args
end

function cls:on_rob(player, args, ... )
	-- body
	assert(self._state == gs.ROB)
	assert(self._rob_player == player)
	player:rob((args.rob > 0 and true or false)) -- decide to do
	
	local res = {}
	res.errorcode = errorcode.SUCCESS
	res.sid = player:get_sid()
	res.rob = args.rob
	if self._dz_player then
		local players = self._env:get_players()
		for i=1,3 do
			players[i]:ready_for_identity()
		end
		res.confirm = true
		res.dz = self._dz_player:get_sid()
	else
		res.confirm = false
		res.your_turn = self._rob_player:get_sid()
		res.countdown = 10
	end
	local l = player:get_last()
	if not l:get_aiflag() and l:get_online() then
		skynet.send(l:get_agent(), "lua", "rob", res)
	end
	local n = player:get_next()
	if not n:get_aiflag() and n:get_online() then
		skynet.send(n:get_agent(), "lua", "rob", res)
	end
	return res
end

function cls:on_identity(p, args, ... )
 	-- body
 	assert(self._state == gs.CRDZ)
 	local res = {}
 	res.errorcode = errorcode.SUCCESS

 	p:set_state(player.state.CI)
 	if self:confirm_identityed() then
 		self:lead_starting()
 		local xargs = {}
	 	xargs.your_turn = self._lead_player:get_sid()
	 	xargs.countdown = 10

	 	local l = p:get_last()
		if not l:get_aiflag() and l:get_online() then
			skynet.send(l:get_agent(), "lua", "identity", xargs)
		end
		local n = p:get_next()
		if not n:get_aiflag() and n:get_online() then
			skynet.send(n:get_agent(), "lua", "identity", xargs)
		end

		res.lead = true
		res.your_turn = self._lead_player:get_sid()
		res.countdown = 10
	else
		res.lead = false
 	end
	return res
end 

function cls:on_lead(player, flag, cards, ... )
	-- body
	log.info("lead player:%d, player: %d", self._lead_player:get_sid(), player:get_sid())
	assert(self._state == gs.LEAD)
	assert(self._lead_player == player)
	if flag then
		for i=1,#cards do
			log.info("%d", cards[i])
		end
		player:lead(cards)
	else
		player:drop()
	end
	local res = {}
	res.errorcode = errorcode.SUCCESS
	res.sid = player:get_sid()
	res.lead = flag
	res.cards = cards
	if self._state == gs.CLOSE then
		res.turn = false
		res.settlement = true
		res.ranked1 = {sid=players[1]:get_sid()}
		res.ranked2 = {sid=players[2]:get_sid()}
		res.ranked3 = {sid=players[3]:get_sid()}
	else
		assert(player ~= self._lead_player)
		res.turn       = true
		res.your_turn  = self._lead_player:get_sid()
		res.countdown  = 10
		res.settlement = false
	end
	local l = player:get_last()
	if not l:get_aiflag() and l:get_online() then
		skynet.send(l:get_agent(), "lua", "lead", res)
	end
	local n = player:get_next()
	if not n:get_aiflag() and n:get_online() then
		skynet.send(n:get_agent(), "lua", "lead", res)
	end
	return res
end

function cls:lead( ... )
	-- body
	-- if self._lead_player:get_aiflag() then
	-- 	self.
	-- end
end

return cls