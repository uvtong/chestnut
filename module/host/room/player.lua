local card = require "card"
local group = require "group"

local state = {}
state.NONE       = 0
state.ENTER      = 1
state.WAIT_START = 2
state.READY      = 3
state.DEAL       = 4
state.WAIT_ROB   = 5
state.WAIT_OROB  = 6
state.WAIT_FAPAI = 7
state.WAIT_ALEAD = 8
state.WAIT_PLEAD = 9
state.WAIT_OLEAD = 10
state.CLOSE      = 11

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
	self._robot = false
	self._name = ""

	self._state = state.NONE
	self._cards = {}
	self._cards_selection = {}
	self._cards_selection_sz = 0
	self._deal_cards = {}

	self._rob = {}
	self._isdizhu = false
	
	self._lastplayerleadg = nil      -- 上位同学出的牌，在场景里表现后比较
	self._mylastleadg = nil          -- 自己上一次出的牌

	self._aiflag = false
	self._airob_cd = 0
	self._ailead_cd = 0


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
	assert(false)
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

function cls:get_selection( ... )
	-- body
	printInfo("get_selection")
	return self._cards_selection
end

function cls:add_selection(card, ... )
	-- body
	printInfo("player add_selection")
	assert(card)
	assert(not card:get_bright())
	card:set_bright(true)
	self._cards_selection[card] = card
	self._cards_selection_sz = self._cards_selection_sz + 1
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

-- 出牌五个函数
function cls:ready_for_alead()
	self._state = state.WAIT_ALEAD
end

function cls:ready_for_plead(g)
	if self._mylastleadg == g then
		-- 饶了一圈
		self:ready_for_alead()
	else
		self._state = state.WAIT_PLEAD
	end
end

function cls:drop( ... )
	-- body
	if self._state == state.WAIT_ALEAD then
		-- 不可能不要，除非你赢了
		assert(false)
	elseif self._state == state.WAIT_PLEAD then
		assert(self._lastplayerleadg)
		self._state = state.WAIT_OLEAD
		self._controller:take_turn_to_lead(self, self._lastplayerleadg)
	end
end

function cls:lead(cards, ... )
	-- body
	if self._controller:get_type() == gt.NETWORK then
		self._cards_selection_sz = #cards
		for i,card in ipairs(self._cards) do
			for i,c in ipairs(cards) do
				if c == card:get_value() then
					self._cards_selection[card] = card
				end
			end
		end
	end
	local order = self:_order_selection()
	if #order <= 0 then
		printInfo("no card")
		return
	end
	local g = group.new(order)
	if self._state == state.WAIT_ALEAD then
		-- 必须上一位玩家大
		if g:get_kind() ~= group.kind.NONE then	
			self._state = state.WAIT_OLEAD
			-- 出牌
			self:_lead(order)
			self._mylastleadg = g
			self:lead_cb()
			return true	
		else
			return false
		end
	elseif self._state == state.WAIT_PLEAD then	
		if g:get_kind() ~= group.kind.NONE and
			g:get_kind() == self._lastplayerleadg:get_kind() then
			if g:mt(self._lastplayerleadg) then
				self._state = state.WAIT_OLEAD
				self:_lead(order)
				self._mylastleadg = g
				self:lead_cb()
				return true
			else
				printInfo("")
				return false
			end
		else
			return false
		end
	end
end

function cls:lead_cb( ... )
	-- body
	if self._controller:confirm_over() then
	else
		self._controller:take_turn_to_lead(self, self._mylastleadg)
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
		printInfo("player into _order_selection")
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

return cls