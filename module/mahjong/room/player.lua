local skynet = require "skynet"
local card = require "card"
local group = require "group"
local log = require "log"
local opcode = require "opcode"
local hutype = require "hutype"
local util = require "util"

local state = {}
state.NONE       = 0
state.ENTER      = 1
state.WAIT_READY = 2
state.READY      = 3
state.WAIT_START = 4
state.SHUFFLE    = 5
state.WAIT_DICE  = 6
state.DICE       = 7
state.WAIT_DEAL  = 8
state.DEAL       = 9
state.WAIT_TURN  = 10
state.TURN       = 11
state.LEAD       = 12

state.CALL       = 13
state.PENG       = 14
state.GANG       = 15
state.HU         = 16

state.OVER       = 24

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
	-- self._online = false  -- user in game
	self._robot  = false  -- user
	self._noone  = true
	self._name   = ""
	self._chip   = 0

	self._state  = state.NONE
	self._takefirst = false
	self._takecardsidx = 1
	self._takecardscnt = 0
	self._takecardslen = 0
	self._takecards = {}

	self._cards  = {}
	self._leadcards = {}
	self._putcards = {}
	self._holdcard = nil

	self._peng = opcode.none
	self._gang = opcode.none
	self._hu = hutype.NONE

	self._canhucards = {}
	self._hucards = {}

	self._hugang = 0
	
	self._cancelcd = nil

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

function cls:get_noone( ... )
	-- body
	return self._noone
end

function cls:set_noone(value, ... )
	-- body
	self._noone = value
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

function cls:get_bet( ... )
	-- body
	return self._bet
end

function cls:set_bet(value, ... )
	-- body
	self._bet = value
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

function cls:clear( ... )
	-- body
	self._cards = {}
end

function cls:_quicksort(low, high, ... )
	-- body
	if low >= high then
		return
	end
	local first = low
	local last = high
	local key = self._cards[first]
	while first < last do
		while first < last and self._cards[last]:mt(key) do
			last = last - 1
		end
		self._cards[first] = self._cards[last]
		while first < last and self._cards[first]:lt(key) do
			first = first + 1
		end
		self._cards[last] = self._cards[first]
	end
	self._cards[first] = key
	self:_quicksort(low, first-1)
	self:_quicksort(first+1, high)   
end

function cls:sort_cards( ... )
	-- body
	self:_quicksort(1, #self._cards)
end

function cls:insert(card, ... )
	-- body
	assert(card)
	local len = #self._cards
	for i=1,len do
		if self._cards[i]:mt(card) then
			for j=len,i,-1 do
				self._cards[j + 1] = self._cards[j]
			end
			self._cards[i] = card
			return i
		end
	end
	self._cards[len+1] = card
	return len + 1
end

function cls:remove_idx(i, ... )
	-- body
	local len = #self._cards
	if i >= 1 and i <= len then
		for i=1,len-1 do
			self._cards[i] = self._cards[i + 1]
		end
		self._cards[len] = nil
	end
end

function cls:lead(c, ... )
	-- body
	assert(c)
	assert(self._state == state.TURN)
	self._state = state.LEAD
	if self._holdcard:get_value() == c then
		local card = self._holdcard
		table.insert(self._leadcards, self._holdcard)
		self._holdcard = nil
		return card
	else
		local card
		local len = #self._cards
		for i=1,len do
			if self._cards[i]:get_value() == c then
				card = self._cards[i]
				table.insert(self._leadcards, self._cards[i])
				for j=i,len-1 do
					self._cards[i] = self._cards[i + 1]
				end
				assert(self._cards[len])
				self._cards[len] = nil
				self:insert(self._holdcard)
				self._holdcard = nil
				break
			end
		end
		return card
	end
end

function cls:take_card( ... )
	-- body
	if self._takecardscnt > 0 then
		local card = self._takecards[self._takecardsidx]
		self._takecards[self._takecardsidx] = nil
		self._takecardscnt = self._takecardscnt - 1

		self._takecardsidx = self._takecardsidx + 1
		if self._takecardsidx > self._takecardslen then
			self._takecardsidx = 1
			self._env:next_takeidx()
		end
		
		return card
	end
end

function cls:check_hu(card, ... )
	-- body
	assert(card)
	local res = hutype.NONE
	local i = self:insert(card)
	assert(i ~= 0)
	local firstse = nil
	local qing = true
	local jiang = 0
	local tong3 = 0
	local lian3 = 0
	local gang = 0
	local len = #self._cards
	local idx = 1

	if #self._putcards > 0 then
		firstse = self._putcards[1][1]:tof()
		for i,v in ipairs(self._putcards) do
			if v:tof() ~= firstse then
				qing = false
			end
			if #v == 4 then
				gang = gang + 1
			elseif #v == 3 then
				tong3 = tong3 + 1
			else
				assert(false)
			end
		end
	else
		firstse = self._cards[1]:tof()
		for i,v in ipairs(self._cards) do
			if v:tof() ~= firstse then
				qing = false
			end
		end
	end

	-- qidui si

	local ok = true
	local a = self._cards[idx]
	idx = idx + 1
	while idx <= len do
		local b = self._cards[idx]
		idx = idx + 1
		if idx > len then
			ok = false
			break
		end
		if a:eq(b) then
			jiang = jiang + 1
			if idx > len then
				break
			end
			local c = self._cards[idx]
			idx = idx + 1
			if a:eq(c) then
				jiang = jiang - 1
				tong3 = tong3 + 1
				local d = self._cards[idx]
				idx = idx + 1
				if a:eq(d) then
					tong3 = tong3 - 1
					jiang = jiang + 2
					gang = gang + 1
					if idx > len then
						break
					end
					local e = self._cards[idx]
					idx = idx + 1
					if e:tof() == a:tof() then
						if e:nof() == a:nof() + 1 then
							local f = self._cards[idx]
							idx = idx + 1
							if f:nof() == e:nof() + 1 then
								jiang = jiang - 2
							else
								ok = false
								break
							end
						else
							ok = false
							break
						end
					else
						ok = false
						break
					end
				elseif a:tof() == d:tof() then
					if a:nof() + 1 == d:nof() then
						local e = self._cards[idx]
						idx = idx + 1
						if idx < len then
							ok = false
							break
						end
						if e:tof() == d:tof() then
							if e:nof() == d:nof() + 1 then
								lian3 = lian3 + 1
							else
								ok = false
								break
							end
						else
							ok = false
							break
						end
					else
					end
				else
				end
			elseif a:tof() == c:tof() then
				if a:nof() + 1 == c:nof() then
					local d = self._cards[idx]
					idx = idx + 1
					if c:eq(d) then
						jiang = jiang + 1
						local e = self._cards[idx]
						idx = idx + 1
						if c:eq(e) then
							jiang = jiang - 1
							tong3 = tong3 + 1
							local f = self._cards[idx]
							idx = idx + 1
							if c:eq(f) then
								jiang = jiang + 2
								tong3 = tong3 - 1
								local g = self._cards[idx]
								idx = idx + 1
								if c:tof() == g:tof() then
									if c:nof() + 1 == g:nof() then
										local h = self._cards[idx]
										idx = idx + 1
										if g:eq(h) then
											jiang = jiang - 3
											jiang = jiang + 1
											lian3 = lian3 + 2
										else
											ok = false
											break
										end
									else
										ok = false
										break
									end
								else
									ok = false
									break
								end
							else
							end
						elseif c:tof() == e:tof() then
							if c:nof() + 1 == e:nof() then
								if idx < len then
									ok = false
									break
								end
								local f = self._cards[idx]
								idx = idx + 1
								if f:eq(e) then
								else
									ok = false
									break
								end
							else
								ok = false
								break
							end
						else
							ok = false
							break
						end
					else
						ok = false
						break
					end
				else
					a = c
					idx = idx - 1
				end
			else
			end
		else
			ok = false
			break
		end
	end

	if ok then
		if len == 2 and jjiang == 1 then
			if gang == 4 and qing then
				self._state = state.WAIT_HU
				return hutype.QINGSHIBALUOHAN
			elseif gang == 4 and not qing then
				self._state = state.WAIT_HU
				return hutype.SHIBALUOHAN
			elseif qing then
				self._state = state.WAIT_HU
				return hutype.QINGJINGOUDIAO
			else
				return hutype.JINGOUDIAO
			end
		elseif len == 5 then
			if jiang == 1 and tong3 == 1 then
				self._state = state.WAIT_HU
				return hutype.DUIDUIHU
			elseif jiang == 1 and lian3 == 1 then
				self._state = state.WAIT_HU
				return hutype.PINGHU
			else
				return hutype.NONE
			end
		else
			self._state = state.WAIT_HU
			return hutype.PINGHU
		end
	else
		return hutype.NONE
	end
end

function cls:hu(card, ... )
	-- body
	assert(self._state == state.WAIT_HU)
	self._state = state.HU
	table.insert(self._hucards, card)
end

function cls:check_gang(card, ... )
	-- body
	assert(card)
	local res = opcode.none
	if self._env._curidx == self._idx then
		local first = nil
		local count = 0
		local len = #self._cards
		for i=1,len do
			if first == nil then
				first = self._cards[i]
				count = 1
			else
				if self._cards[i]:eq(first) then
					count = count + 1
				else
					if count == 3 then
						if first:eq(card) then
							self._gang = {}
							self._gang.idx = self._idx
							self._gang.card = card
							self._gang.code = opcode.angang
							res = opcode.angang
							return res
						end
					elseif count == 4 then
						self._gang = {}
						self._gang.idx = self._idx
						self._gang.card = first
						self._gang.code = opcode.angang
						res = opcode.angang
						return res
					else
						first = nil
						count = 0
					end
				end
			end
		end

		for i,v in ipairs(self._putcards) do
			if #v == 3 then
				if v[1]:eq(card) then
					self._gang = {}
					self._gang.idx = self._idx
					self._gang.card = card
					self._gang.code = opcode.bugang
					res = opcode.bugang
					return res
				end
			end
		end
		return res
	else
		local first = nil
		local count = 0
		local len = #self._cards
		for i=1,len do
			if first == nil then
				first = self._cards[i]
				count = 1
			else
				if self._cards[i]:eq(first) then
					count = count + 1
				else
					if count == 3 then
						if first:eq(card) then
							self._gang = {}
							self._gang.idx = self._idx
							self._gang.card = card
							self._gang.code = opcode.zhigang
							res = opcode.angang
							return res
						end
					else
						first = nil
						count = 0
					end
				end
			end
		end
		return res
	end
end

function cls:gang(info, ... )
	-- body
	assert(info and info.idx == self._idx)
	if info.code == opcode.zhigang then
		assert(info.card == self._gang.card:get_value())
		assert(info.code == opcode.zhigang)
		self._state = state.GANG

		local cards = {}
		local len = #self._cards
		local idx = 0
		for i=1,len do
			if self._cards[i]:eq(self._gang.card) then
				table.insert(cards, self._cards[i])
				idx = i
			end
			if #cards == 3 then
				break
			end
		end
		assert(#cards == 3)
		assert(idx ~= 0)
		for i=idx+1,len do
			self._cards[i-3] = self._cards[i]
			self._cards[i] = nil
		end
		table.insert(cards, self._gang.card)
		table.insert(self._putcards, cards)
	elseif info.code == opcode.angang then
		assert(info.card == self._gang.card:get_value())
		assert(info.code == opcode.angang)
		self._state = state.GANG
		local cards = {}
		local idx = 0
		local len = #self._cards
		for i=1,len do
			if self._cards[i]:eq(self._gang.card) then
				table.insert(cards, self._cards[i])
				idx = i
			end
			if #cards == 4 then
				break
			end
		end
		assert(#cards == 4)
		for j=idx-3,len-4 do
			self._cards[j] = self._cards[j + 4]
			self._cards[j + 4] = nil
		end
		table.insert(self._putcards, cards)
	elseif info.code == opcode.bugang then
		assert(self._gang.code == opcode.bugang)
		assert(#self._putcards > 0)
		for i,v in ipairs(self._putcards) do
			if #v == 3 and v[1]:eq(self._gang.card) then
				table.insert(v, self._gang.card)
				if self._gang.card == self._holdcard then
					self._holdcard = nil
				else
					local idx = 0
					local len = #self._cards
					for i=1,len do
						if self._cards[i]:eq(self._gang.card) then
							idx = i
							break
						end
					end
					assert(idx ~= 0)
					for j=idx,len-1 do
						self._cards[j] = self._cards[j + 1]
						self._cards[j + 1] = nil
					end
					break
				end
			end
		end
	else
		assert(info.code == opcode.none)
	end
end

function cls:check_peng(card, ... )
	-- body
	local count = 0
	local len = #self._cards
	for i=1,len do
		if self._cards[i]:eq(card) then
			count = count + 1
		end
		if count == 2 then
			break
		end
	end
	if count == 2 then
		self._peng = {}
		self._peng.idx = self._idx
		self._peng.card = card
		self._peng.code = opcode.peng
		return opcode.peng
	else
		self._peng = {}
		self._peng.idx = self._idx
		self._peng.card = nil
		self._peng.code = opcode.peng
		return opcode.none
	end
end

function cls:peng(info, ... )
	-- body
	assert(info.idx == self._idx)
	assert(self._peng.code == opcode.peng)
	self._state = state.PENG
	assert(#self._cards % 2 == 1, #self._cards)
	local len = #self._cards
	local cards = {}
	local idx = 0
	for i,v in ipairs(self._cards) do
		if v:eq(self._peng.card) then
			table.insert(cards, v)
			idx = i
		end
		if #cards == 2 then
			break
		end
	end
	assert(#cards == 2)
	table.insert(cards, card)
	for i=idx-1,len-2 do
		self._cards[i] = self._cards[i + 2]
		self._cards[i + 2] = nil
	end
	table.insert(self._putcards, cards)
end

function cls:timeout(ti, ... )
	-- body
	self._cancelcd = util.set_timeout(ti, function ( ... )
		-- body
		if self._state == state.TURN then
			self._env:lead(self._idx, self._holdcard:get_value())
		elseif self._state == state.CALL then
			self._env:timeout_call(self._idx)
		end
	end)
	assert(self._cancelcd)
end

function cls:cancel_timeout( ... )
	-- body
	self._cancelcd()
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