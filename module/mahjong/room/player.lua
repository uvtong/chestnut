local skynet = require "skynet"
local card = require "card"
local group = require "group"
local log = require "log"

local state = {}
state.NONE       = 0
state.ENTER      = 1
state.WAIT_START = 2
state.SHUFFLE    = 3
state.WAIT_DICE  = 4
state.DICE       = 5
state.WAIT_DEAL  = 6
state.DEAL       = 7
state.WAIT_TURN  = 8
state.TURN       = 9

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
	self._bet    = 0

	self._state  = state.NONE
	self._takecardsidx = 1
	self._takecardsend = 0
	self._takecardscnt = 0
	self._takecardslen = 0
	self._takecards = {}

	self._cards  = {}
	self._leadcards = {}

	self._pengcards = {}
	self._gangcards = {}

	self._holdcard = nil

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

function cls:insert(card, ... )
	-- body
	local len = #self._cards
	for i=1,len do
		if self._cards[i]:tof() == card:tof() then
			if self._cards[i]:nof() <= card:nof() then
			else
				for j=len,i,-1 do
					self._cards[j + 1] = self._cards[i]
				end
				self._cards[i] = card
				return i
			end
		elseif self._cards[i]:tof() < card:tof() then
		else
			for j=len,i,-1 do
				self._cards[j + 1] = self._cards[i]
			end
			self._cards[i] = card
			return i
		end
	end
	return 0
end

function cls:lead(c, ... )
	-- body
	assert(c)
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
		if self._takecardsidx == self._takecardsend then
			assert(self._takecardscnt == 0)
		end
		self._takecardsidx = self._takecardsidx + 1

		if self._takecardsidx > self._takecardslen then
			self._takecardsidx = 1
		end
		return card
	end
end

function cls:check_hu(card, ... )
	-- body
	local i = self:insert(card)
	assert(i ~= 0)
	local jiang = 0
	local len = #self._cards
	local idx = 1
	local a = self._cards[idx]
	idx = idx + 1
	while idx <= len do
		local b = self._cards[idx]
		if a:tof() == b:tof() then
			if a:nof() == b:nof() then
				jiang = jiang + 1
				idx = idx + 1
				if idx > len then
					if jiang == 1 then
						return true
					else
						return false
					end
				end
				local c = self._cards[idx]
				if a:tof() == c:tof() then
					if a:nof() == c:nof() then
						jiang = jiang - 1
						idx = idx + 1
						if idx > len then
							if jiang == 1 then
								return true
							else
								return false
							end
						end
						local d = self._cards[idx]
						if a:tof() == d:tof() then
							if a:nof() == d:nof() then -- four same
								idx = idx + 1
								if idx > len then
									return false
								end
								local e = self._cards[idx]
								if a:tof() == e:tof() then
									if a:nof() + 1 == e:tof() then
										-- deep
									else
										return false
									end
								else
									a = e
								end
							elseif a:nof() + 1 == d:nof() then
								idx = idx + 1
								if idx > len then
									return false
								end
								local e = self._cards[idx]
								if a:tof() == e:tof() then
									if a:nof() + 2 == e:nof() then
										jiang = jiang + 1
										idx = idx + 1
										if idx > len then
											if jiang == 1 then
												return true
											else
												return false
											end
										end
										a = self._cards[idx]
									else
										return false
									end
								else
									return false
								end
							else
								return false
							end
						else
							a = d
						end
					elseif a:nof() + 1 == c:nof() then
						idx = idx + 1
						if idx > len then
							return false
						end
						local d = self._cards[idx]
						if a:tof() == d:tof() then
							if c:nof() == d:nof() then
								jiang = jiang + 1
								idx = idx + 1
								if idx > len then
									return false
								end
								local e = self._cards[idx]
								if a:tof() == e:tof() then
									if d:nof() == e:nof() then
										jiang = jiang - 1
										idx = idx + 1
										if idx > len then
											return false
										end
										a = self._cards[idx]
									elseif d:nof() + 1 == e:nof() then
										jiang = jiang - 1
										idx = idx + 1
										if idx > len then
											return false
										end
										local f = self._cards[idx]
										if a:tof() == f:tof() then
											if e:nof() == f:nof() then
												idx = idx + 1
												if idx > len then
													return false
												end
												a = self._cards[idx]
											else
												return false
											end
										else
											return false
										end
									else
										return false
									end
								else
									return false
								end
							else
								return false
							end
						else
							return false
						end
					else
						return false
					end
				else
					idx = idx + 1
					if idx > len then
						return false
					end
					a = self._cards[idx]
				end
			elseif a:nof() + 1 == b:nof() then
				idx = idx + 1
				if idx > len then
					return false
				end
				local c = self._cards[idx]
				if a:tof() == c:tof() then
					if b:nof() + 1 == c:nof() then
						idx = idx + 1
						if idx > len then
							return false
						end
						a = self._cards[idx]
					else
						return false
					end
				else
					return false
				end
			else
				return false
			end
		else
			return false
		end
	end
	assert(jiang == 1)
	return true
end

function cls:hu( ... )
	-- body
end

function cls:check_gang(card, ... )
	-- body
	local count = 0
	local len = #self._cards
	for i=1,len do
		if self._cards[i]:tof() == card:tof() then
			if self._cards[i]:nof() == card:nof() then
				count = count + 1
			end
		elseif self._cards[i]:tof() < card:tof() then
		else
			break
		end
	end
	if count >= 3 then
		return true
	end
	return false
end

function cls:gang(card, ... )
	-- body
	local count = 0
	local cards = {}
	local len = #self._cards
	for i=1,len do
		if self._cards[i]:get_value() == c then
			table.insert()
			if self._cards[i]:nof() == card:nof() then
				cards[#cards] = self._cards[i]
			end
		elseif self._cards[i]:tof() < card:tof() then
		else
			break
		end
	end
	self._gangcards[#self._gangcards + 1] = cards
end

function cls:check_peng(c, ... )
	-- body
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