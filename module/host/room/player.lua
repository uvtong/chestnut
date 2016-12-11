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
	self._last   = false
	self._next   = false
	self._idx    = 0      -- players index
	self._online = false  -- user
	self._robot  = false  -- user
	self._name   = ""

	self._state  = state.NONE
	self._cards  = {}
	self._cards_selection = {}
	self._cards_selection_sz = 0

	self._rob    = {}
	self._isdizhu = false
	
	self._lastplayerleadg = nil      -- 上位同学出的牌，在场景里表现后比较
	self._mylastleadg = nil          -- 自己上一次出的牌

	self._aiflag = false  -- ai
	self._airob_cd = 0
	self._ailead_cd = 0

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

function cls:set_state(s, ... )
	-- body
	self._state = s
end

function cls:get_state( ... )
	-- body
	return self._state
end

function cls:get_rob( ... )
	-- body
	return self._rob
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
	for i,v in ipairs(self._cards) do
		v:clear()
	end
end

function cls:get_aiflag( ... )
	-- body
	return self._aiflag
end

function cls:set_aiflag(value, ... )
	-- body
	self._aiflag = value
end

function cls:get_selection( ... )
	-- body
	return self._cards_selection
end

function cls:add_selection(card, ... )
	-- body
	assert(card)
	assert(not card:get_bright())
	card:set_bright(true)
	self._cards_selection[card] = card
	self._cards_selection_sz = self._cards_selection_sz + 1
end

function cls:remove_selection(card, ... )
	-- body
	assert(card and card:get_bright())
	card:set_bright(false)
	self._cards_selection[card] = nil
	self._cards_selection_sz = self._cards_selection_sz - 1
	assert(self._cards_selection_sz >= 0)
end

function cls:clear_selection( ... )
	-- body
	if self._cards_selection_sz > 0 then
		for k,v in pairs(self._cards_selection) do
			v:set_bright(false)
		end
		self._cards_selection = {}
		self._cards_selection_sz = 0
	end
end

function cls:start( ... )
	-- body
	self._state = state.NONE
	self._rob = {}
	self._is_dz = false
	self._deal_cards = {}
	self._cards = {}
end

function cls:close( ... )
	-- body
end

function cls:ready_for_ready( ... )
	-- body
	log.info("ready_for_ready")
	self._state = state.WAIT_START
	if self._aiflag then
		local cb = cc.handler(self, cls.ai)
		skynet.timeout(100 * 2, cb) -- 2s
	end
end

-- deal 3 function.
function cls:ready_for_deal( ... )
	-- body
	self._state = state.DEAL
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

function cls:deal(c, ... )
	-- body
	log.info("sid: %d, card: %d", self._sid, c:get_value())
	assert(c)
	self:insert_card(self._cards, c)
	self:deal_cb(c)
end

function cls:deal_cb(c)
	-- body
	assert(c)
	local controller = self._env:get_controller("game")
	controller:take_turn_to_deal(self)
end

function cls:ready_for_dealed( ... )
	-- body
	log.info("sid: %d dealed", self._sid)
	self._state = state.DEALED
	if self._aiflag then
		local cb = cc.handler(self, cls.ai)
		skynet.timeout(100 * 2, cb)
	end
end

-- rob
function cls:ready_for_rob( ... )
	-- body
	self._state = state.WAIT_ROB
	local idx = #self._rob
	if idx == 0 then
		idx = idx + 1
		self._rob[idx] = false
	elseif idx == 1 then
		idx = idx + 1
		self._rob[idx] = false
	end
	assert(idx <= 2)
	if self._aiflag then
		local cb = cc.handler(self, cls.ai)
		skynet.timeout(100 * 2, cb)
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
		controller:confirm_identity(self)
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

function cls:deal_dz(card, ... )
	-- body
	assert(card)
	self:insert_card(self._cards, card)
	local controller = self._env:get_controller("game")
	controller:take_turn_to_deal_dz()
end

function cls:ready_for_identity( ... )
	-- body
	self._state = state.WAIT_CI
	if self._aiflag then
		local cb = cc.handler(self, cls.ai) 
		skynet.timeout(100, cb)
	end
end

-- 出牌五个函数
function cls:ready_for_alead()
	self._state = state.WAIT_ALEAD
	if self._aiflag then
		local cb = cc.handler(self, cls.ai)
		skynet.timeout(100 * 3, cb)
	end
end

function cls:ready_for_plead(g)
	if self._mylastleadg == g then
		-- 饶了一圈
		self:ready_for_alead()
	else
		self._state = state.WAIT_PLEAD
		self._lastplayerleadg = g
		if self._aiflag then
			local cb = cc.handler(self, cls.ai)
			skynet.timeout(100 * 3, cb)
		end
	end
end

function cls:drop( ... )
	-- body
	if self._state == state.WAIT_ALEAD then
		-- 不可能不要，除非你赢了
		assert(false)
	elseif self._state == state.WAIT_PLEAD then
		self._state = state.WAIT_OLEAD
		self:drop_cb()
	end
end

function cls:drop_cb( ... )
	-- body
	local controller = self._env:get_controller("game")
	controller:take_turn_to_lead(self, self._lastplayerleadg)
end

function cls:lead(cards, ... )
	-- body
	assert(self._cards_selection_sz == 0)
	local num = 0
	for k,v in pairs(self._cards_selection) do
		num = num + 1
	end
	assert(num == 0)
	for i,v in ipairs(cards) do
		for i,card in ipairs(self._cards) do
			if v == card:get_value() then
				self:add_selection(card)
				break
			end
		end
	end
	-- real lead
	if self._state == state.WAIT_ALEAD then
		local order = self:_order_selection()
		self._mylastleadg = group.new(order)
		self:_lead(order)
		self:clear_selection()
	elseif self._state == state.WAIT_PLEAD then
		local order = self:_order_selection()
		local g = group.new(order)
		if g:mt(self._lastplayerleadg) then
			self._mylastleadg = g
			self:_lead(order)
			self:clear_selection()
		else
			assert(false)
		end
	end
	self:lead_cb()
end

function cls:lead_cb( ... )
	-- body
	local controller = self._env:get_controller("game")
	if controller:confirm_over(self) then
	else
		controller:take_turn_to_lead(self, self._mylastleadg)
	end
end

function cls:_lead(order, ... )
	-- body
	assert(order)
	local sz = #order
	for i=sz,1,-1 do
		local card = order[i]
		local idx = card:get_idx()
		local sz = #self._cards
		if idx == sz then
			self._cards[idx] = nil
		else
			for i=idx+1,sz do
				local tmp = self._cards[i]
				self._cards[i-1] = tmp
				tmp:set_idx(i-1)
				if i == sz then
					self._cards[i] = nil
				end
			end
		end
	end
end

function cls:_order_selection( ... )
	-- body
	local order = {}
	for k,card in pairs(self._cards_selection) do
		assert(card:get_bright())
		local idx = card:get_idx()
		local sz = #order
		if sz == 0 then
			table.insert(order, card)
		else
			for i=sz,1,-1 do
				local other = order[i]
				local other_idx = other:get_idx()
				if other_idx > idx then
					order[i + 1] = other
				else
					order[i + 1] = card
					break
				end
			end
			order[1] = card
		end
	end
	return order
end

function cls:_calc_plead( ... )
	-- body
	local g = self._lastplayerleadg
	assert(g:get_kind() ~= group.kind.NONE)
	if g:get_kind() == group.kind.SINGLE then
		if self._cards_selection_sz > 1 then
			-- 这里是最不好弄得

		elseif self._cards_selection_sz == 1 then
		else 
			local cards = g:get_cards()
			local dst_card = cards[1]

			local sz = #self._cards
			for i=sz,1,-1 do
				local card = self._cards[i]
				if card:mt(dst_card) then
					self:add_selection(card)
					break
				end
			end
		end
	end
	if self._cards_selection_sz == 1 then
		printInfo("_cards_selection more then 0")
		self:lead()
	elseif self._cards_selection_sz <= 0 then
		printInfo("_cards_selection less then 0")
		self:drop()
	else
		assert(false)
	end
end

function cls:_calc_alead( ... )
	-- body
	assert(#self._cards_selection == 0)
	local sz = #self._cards
	local card = self._cards[sz]
	self:add_selection(card)
	self:lead()
end

function cls:ai( ... )
	-- body
	assert(self._aiflag)
	if self._state == state.WAIT_START then
		local controller = self._env:get_controller("game") 
		controller:on_ready(self, true)
	elseif self._state == state.DEALED then
		local args = {
			sid = self._sid
		}
		local controller = self._env:get_controller("game") 
		controller:on_dealed(self, args)
	elseif self._state == state.WAIT_ROB then
		local args = {
			sid = self._sid,
        	rob = 1
		}
		local controller = self._env:get_controller("game")
		controller:on_rob(self, args)
	elseif self._state == state.WAIT_CI then
		local controller = self._env:get_controller("game")
		controller:on_identity(self)
	elseif self._state == state.WAIT_ALEAD then
		local cs = {}
		local idx = 1
		local card = self._cards[idx]
		table.insert(cs, card:get_value())

		local controller = self._env:get_controller("game")
		controller:on_lead(self, true, cs)
	elseif self._state == state.WAIT_PLEAD then
		local cs = {}
		if self._lastplayerleadg:get_kind() == group.kind.SINGLE then
			local cards = self._lastplayerleadg:get_cards()
			local dst_card = cards[1]

			local sz = #self._cards
			for i=sz,1,-1 do
				local card = self._cards[i]
				if card:mt(dst_card) then
					table.insert(cs, card:get_value())
					break
				end
			end
		end
		if #cs > 0 then
			local controller = self._env:get_controller("game")
			controller:on_lead(self, true, cs)
		else
			local controller = self._env:get_controller("game")
			controller:on_lead(self, false, cs)
		end
	end
end

return cls