local skynet = require "skynet"
local card = require "card"
local player = require "player"
local log = require "log"
local list = require "list"
local util = require "util"
local opcode = require "opcode"
local errorcode = require "errorcode"
local hutype = require "hutype"

local state = {}
state.NONE       = 0
state.START      = 1
state.CREATE     = 2
state.JOIN       = 3
state.READY      = 4
state.SHUFFLE    = 5
state.DICE       = 6
state.TURN       = 7
state.LEAD       = 8
state.PENG       = 9
state.BUGANG     = 10
state.ZHIGANG    = 11
state.ANGANG     = 12
state.HU1        = 13
state.HU2        = 14
state.HU3        = 15
state.CALL       = 16
state.OVER       = 17

local SICHUAN = 1
local SHANXI = 2

local cls = class("rcontext")

function cls:ctor( ... )
	-- body
	self._id = 0
	self._local = SICHUAN
	self._maxmultiple = 8
	self._multiple = {}
	if self._local == SICHUAN then
		self._multiple[hutype.PINGHU] = 1
		self._multiple[hutype.DUIDUIHU] = 2
		self._multiple[hutype.QINGYISE] = 4
		self._multiple[hutype.QIDUI] = 4
		self._multiple[hutype.JINGOUDIAO] = 4
		self._multiple[hutype.QINGDUIDUI] = 8
		self._multiple[hutype.LONGQIDUI] = 16 > self._maxmultiple and self._maxmultiple or 16
		self._multiple[hutype.QINGQIDUI] = 16 > self._maxmultiple and self._maxmultiple or 16
		self._multiple[hutype.QINGJINGOUDIAO] = 16 > self._maxmultiple and self._maxmultiple or 16
		self._multiple[hutype.QINGLONGQIDUI] = 32 > self._maxmultiple and self._maxmultiple or 32
		self._multiple[hutype.SHIBALUOHAN] = 64 > self._maxmultiple and self._maxmultiple or 64
		self._multiple[hutype.QINGSHIBALUOHAN] = 128 > self._maxmultiple and self._maxmultiple or 128
	elseif self._local == SHANXI then
		self._multiple[hutype.PINGHU] = 1
		self._multiple[hutype.DUIDUIHU] = 1
		self._multiple[hutype.QINGYISE] = 1
		self._multiple[hutype.QIDUI] = 1
		self._multiple[hutype.JINGOUDIAO] = 1
		self._multiple[hutype.QINGDUIDUI] = 1
		self._multiple[hutype.LONGQIDUI] = 1
		self._multiple[hutype.QINGQIDUI] = 1
		self._multiple[hutype.QINGJINGOUDIAO] = 1
		self._multiple[hutype.QINGLONGQIDUI] = 1
		self._multiple[hutype.SHIBALUOHAN] = 1
		self._multiple[hutype.QINGSHIBALUOHAN] = 1
	end

	self._players = {}
	self._max = 4
	for i=1, self._max do
		local tmp = player.new(self)
		tmp._idx = i
		table.insert(self._players, tmp)
	end

	self._cards = {}
	self._cardssz = 108
	self:init_cards()

	self._online = 0
	self._host = nil
	
	self._prestate = state.NONE
	self._state = state.NONE
	-- self._cards = {}

	self._lastwin  = nil  -- last
	
	self._lastidx  = nil  -- last time lead from who
	self._lastcard = nil -- last time lead

	self._firsttake = nil
	self._firstidx = nil
	self._curtake = nil
	self._curidx = nil  -- player
	self._curcard = nil
	
	self._takeround = 1

	return self
end

function cls:set_id(value, ... )
	-- body
	self._id = value
end

function cls:get_online( ... )
	-- body
	return self._online
end

function cls:incre_online( ... )
	-- body
	self._online = self._online + 1
	if self._online > self._max then
		self._online = self._max
		assert(false)
	end
end

function cls:decre_online( ... )
	-- body
	self._online = self._online - 1
	if self._online < 0 then
		self._online = 0
		assert(false)
	end
end

function cls:find_noone( ... )
	-- body
	if self._online > self._max then
		return false
	end
	assert(self._online >= 0)
	for i=1,self._max do
		if self._players[i]._noone then
			return self._players[i]
		end
	end
end

function cls:get_player_by_uid(uid, ... )
	-- body
	assert(uid)
	for i=1,self._max do
		local p = assert(self._players[i])
		if p._uid == uid then
			return p
		end
	end
end

function cls:get_player_by_sid(sid, ... )
	-- body
	assert(sid)
	for i=1,self._max do
		local p = assert(self._players[i])
		if p._sid == sid then
			return p
		end
	end
end

function cls:init_cards( ... )
	-- body
	for i=1,3 do
		for j=1,9 do
			for k=1,4 do
				table.insert(self._cards, card.new(i, j, k))
			end
		end
	end
end

function cls:check_state(idx, state, ... )
	-- body
	self._players[idx]._state = state
	for i=1,4 do
		if self._players[i]._state ~= state then
			return false
		end
	end
	return true
end

function cls:clear_state(state, ... )
	-- body
	assert(state)
	for i=1,4 do
		self._players[i]._state = state
	end
end

function cls:push_client(name, args, ... )
	-- body
	for i=1,self._max do
		local p = self._players[i]
		if not p._noone then
			skynet.send(p._agent, "lua", name, args)
		end
	end
end

function cls:next_idx( ... )
	-- body
	self._curidx = self._curidx + 1
	if self._curidx > 4 then
		self._curidx = 1
	end
	return self._curidx
end

function cls:next_takeidx( ... )
	-- body
	self._curtake = self._curtake + 1
	if self._curtake > 4 then
		self._curtake = 1
	end
	return self._curtake
end

function cls:start(uid, ... )
	-- body
	assert(uid)
	self._host = uid
	-- local cb = cc.handler(self, cls.check_start)
	-- util.set_timeout(400, cb)
end

function cls:take_card( ... )
	-- body
	local takep = self._players[self._curtake]
	if takep._takecardscnt > 0 then
		local card = takep:take_card()
		assert(card)
		return card
	else
		self._curtake = self:next_takeidx()
		if self._curtake == self._firsttake then
			self:over()
		else
			takep = self._players[self._curtake]
			local card = takep:take_card()
			assert(card)
			return card	
		end
	end
end

function cls:check_start( ... )
	-- body
	if self._online >= 2 then
		self:ready()
	else
		local cb = cc.handler(self, cls.check_start)
		util.set_timeout(400, cb)
	end
end

function cls:join(uid, sid, agent, name, ... )
	-- body
	self._state = state.JOIN
	local me = assert(self:find_noone())
	if me then

		me:set_uid(uid)
		me:set_sid(sid)
		me:set_agent(agent)
		me:set_name(name)

		me:set_noone(false)
		self:incre_online()

		local p = {
			name = me:get_name(),
			idx = me:get_idx(),
			sid = me:get_sid()
		}

		log.info("uid:%d, host:%d", uid, self._host)
		if uid == self._host and uid ~= nil then
			log.info("room host create.")
			return p
		else
			local ps = {}
			for i,v in ipairs(self._players) do
				if not v:get_noone() and v:get_uid() ~= uid then
					local p = {
						name = v:get_name(),
						idx = v:get_idx(),
						sid = v:get_sid()
					}
					table.insert(ps, p)
				end
			end
			local args = {}
			args.p = p
			for k,v in pairs(self._players) do
				if not v._noone and v ~= me then
					skynet.send(v._agent, "lua", "join", args)
				end
			end

			local res = {}
			res.errorcode = errorcode.SUCCESS
			res.ps = ps
			res.me = p
			res.roomid = self._id
			return res
		end
	else
		log.info("con't found a noone player.")
		local res = {}
		res.errorcode = errorcode.FAIL
		return res
	end
end

function cls:leave(uid, ... )
	-- body
	local p = assert(self:get_player_by_uid(uid))
	p:set_noone(true)
	p:set_online(false)
end

function cls:step(idx, ... )
	-- body
	assert(idx)
	if self._state == state.JOIN then
		local p = self._players[idx]
		assert(not p:get_noone())
		if self:check_state(idx, player.state.WAIT_READY) then
			self:take_ready()
		end
	elseif self._state == state.READY then
		local p = self._players[idx]
		assert(not p:get_noone())
		if self:check_state(idx, player.state.WAIT_START) then
			self:take_shuffle()
		end
	elseif self._state == state.SHUFFLE then
		local p = self._players[idx]
		assert(not p:get_noone())
		if self:check_state(idx, player.state.WAIT_DICE) then
			self:take_dice()
		end
	elseif self._state == state.DICE then
		local p = self._players[idx]
		assert(not p:get_noone())
		if self:check_state(idx, player.state.WAIT_DEAL) then
			self:take_deal()
		end
	elseif self._state == state.DEAL then
		local p = self._players[idx]
		assert(not p:get_noone())
		if self:check_state(idx, player.state.WAIT_TURN) then
			self._curidx = self._firstidx -- reset curidx for turn 
			self._curcard = self:take_card()
			self:take_turn()
		end
	elseif self._state == state.LEAD then
		local p = self._players[idx]
		assert(not p:get_noone())
		if self:check_state(idx, player.state.WAIT_TURN) then
			local opcodes = {}
			for i=1,4 do
				if i ~= idx then
					local info = {
						idx = i,
					}
					local hucode = self._players[i]:check_hu(self._lastcard)
					local pengcode = self._players[i]:check_gang(self._lastcard)
					local gangcode = self._players[i]:check_peng(self._lastcard)
					if hucode == hucode.NONE and
						pengcode == opcode.peng and
						gangcode == opcode.none then
					else
						info.peng = pengcode
						info.gang = gangcode 
						info.hucode = hucode
						table.insert(opcodes, info)
					end
				end
			end
			if #opcodes > 0 then
				self:take_call(opcodes)
			else
				self:guo()
			end
		end
	elseif self._state == state.PENG then
		local p = self._players[idx]
		assert(not p:get_noone())
		if self:check_state(idx, player.state.WAIT_TURN) then
			self:take_turn()
		end
	elseif self._state == state.GANG then
		local p = self._players[idx]
		assert(not p:get_noone())
		if self:check_state(idx, player.state.WAIT_TURN) then
			self._curcard = self:take_card()
			self:take_turn()
		end
	end
end

function cls:take_ready( ... )
	-- body
	self._state = state.READY
	self:clear_state(player.state.READY)
	self:push_client("ready")
end

function cls:take_shuffle( ... )
	-- body
	self._state = state.SHUFFLE
	self:clear_state(player.state.SHUFFLE)

	assert(#self._cards == 108)
	for i=107,1,-1 do
		local swp = math.floor(math.random(1, 1000)) % 108 + 1
		while swp == i do
			swp = math.floor(math.random(1, 1000)) % 108 + 1
		end
		local tmp = assert(self._cards[i])
		self._cards[i] = assert(self._cards[swp], swp)
		self._cards[swp] = tmp
	end
	assert(#self._cards == 108)

	local p1 = {}
	for i=1,28 do
		local card = assert(self._cards[i])
		self._players[1]._takecards[i] = card
		table.insert(p1, card:get_value())
	end
	self._players[1]._takecardsidx = 1
	self._players[1]._takecardslen = 28
	self._players[1]._takecardscnt = 28
	assert(#p1 == 28)
	local p2 = {}
	for i=1,28 do
		local card = assert(self._cards[28 + i])
		self._players[2]._takecards[i] = card
		table.insert(p2, card:get_value())
	end
	self._players[2]._takecardsidx = 1
	self._players[2]._takecardslen = 28
	self._players[2]._takecardscnt = 28
	assert(#p2 == 28)
	local p3 = {}
	for i=1,26 do
		local card = assert(self._cards[28*2 + i])
		self._players[3]._takecards[i] = card
		table.insert(p3, card:get_value())
	end
	self._players[3]._takecardsidx = 1
	self._players[3]._takecardslen = 26
	self._players[3]._takecardscnt = 26
	assert(#p3 == 26)
	local p4 = {}
	for i=1,26 do
		local card = assert(self._cards[28*2 + 26 + i])
		self._players[4]._takecards[i] = card
		table.insert(p4, card:get_value())
	end
	self._players[4]._takecardsidx = 1
	self._players[4]._takecardslen = 26
	self._players[4]._takecardscnt = 26
	assert(#p4 == 26)
	local args = {}
	args.p1 = p1
	args.p2 = p2
	args.p3 = p3
	args.p4 = p4

	if self._lastwin and self._lastwin > 0 and self._lastwin <= 4 then
		args.first = self._lastwin
	else
		args.first = assert(self._host)
	end
	self._firstidx = args.first

	self:push_client("shuffle", args)
end

function cls:take_dice( ... )
	-- body
	self._state = state.DICE
	local d1 = 1
	local d2 = 4
	local min = math.min(d1, d2)
	local point = d1 + d2
	while point > 4 do
		point = point - 4
	end
	assert(point > 0 and point <= 4)

	self._firsttake = point
	self._firstidx = 1
	self._curtake = point
	self._curidx = 1

	self._takeround = 1
	local takep = self._players[self._curtake]
	takep._takecardsidx = min * 2 + 1
	takep._takefirst = true

	local args = {}
	args.first = self._firstidx
	args.firsttake = self._firsttake
	args.d1 = d1
	args.d2 = d2
	self:push_client("dice", args)
end

function cls:take_deal( ... )
	-- body
	self._state = state.DEAL
	self:clear_state(player.state.DEAL)

	for i=1,4 do
		for j=1,4 do
			local p = self._players[self._curidx]
			if i == 4 then
				local card = self:take_card()
				assert(card)
				p:insert(card)
			else
				for i=1,4 do
					local card = self:take_card()
					assert(card)
					p:insert(card)	
				end
			end
			self._curidx = self:next_idx()
		end
	end
	
	local p1 = self._players[1]:get_cards_value()
	local p2 = self._players[2]:get_cards_value()
	local p3 = self._players[3]:get_cards_value()
	local p4 = self._players[4]:get_cards_value()

	local args = {}
	args.firstidx = self._firstidx
	args.firsttake = self._firsttake
	args.p1 = p1
	args.p2 = p2
	args.p3 = p3
	args.p4 = p4

	self:push_client("deal", args)
end

function cls:take_turn( ... )
	-- body
	self._state = state.TURN
	self:clear_state(player.state.TURN)

	if self._state == PENG then
		local args = {}
		args.your_turn = self._curidx
		args.countdown = 10
		args.type = 0
		args.card = self._curcard:get_value()

		self:push_client("take_turn", args)
	else
		self._players[self._curidx]._holdcard = self._curcard

		local args = {}
		args.your_turn = self._curidx
		args.countdown = 10
		args.type = 1
		args.card = self._curcard:get_value()

		self:push_client("take_turn", args)
	end
end

function cls:take_call(opcodes, ... )
	-- body
	self._state = state.CALL
	-- self:clear_state(player.state.CALL)

	local args = {}
	args.your_turn = 0
	args.countdown = 10
	args.opcodes = opcodes

	self:push_client("call", args)
end

function cls:lead(idx, c, ... )
	-- body
	assert(self._state == state.TURN)
	if self._players[idx]._state == player.state.TURN then
		self._state = state.LEAD
		self:clear_state(player.state.LEAD)

		self._players[idx]:cancel_timeout()
		local card = self._players[idx]:lead(c)
		assert(card:get_value() == c)
		self._lastidx = idx
		self._lastcard = card
		self._curidx = idx
		local args = {}
		args.idx = idx
		args.card = c
		self:push_client("lead", args)
	else
		log.info("player %d has leaded", idx)
	end
end

function cls:hu(idx, c, ... )
	-- body
	assert(self._prestate == start.HU1)
	assert(idx ~= self._curidx)
	assert(self._players[idx]:check_hu(self._lastcard))
	assert(c == self._lastcard:get_value())

	self._players[idx]:hu(self._lastcard)
	self._curidx = idx

	local args = {}
	args.idx = idx
	args.card = self._lastcard:get_value()
	self:push_client("hu", args)
end

function cls:peng(idx, c, ... )
	-- body
	assert(idx ~= self._curidx)
	assert(self._players[idx]:check_peng(self._lastcard))

	self._state = state.PENG
	
	self._players[idx]:peng(self._lastcard)
	self._curidx = idx

	local args = {}
	args.idx = idx
	args.card = self._lastcard:get_value()

	self:push_client("peng", args)
end

function cls:gang(idx, c, ... )
	-- body
	assert(idx ~= self._curidx)
	assert(self._players[idx]:check_gang(self._lastcard))

	self._players[idx]:gang(self._lastcard)
	self._curidx = idx

	local args = {}
	args.idx = idx
	args.card = self._lastcard:get_value()

	self:push_client("gang", args)
end

function cls:guo(idx, ... )
	-- body
	self._curidx = self:next_idx()
	self._curcard = self:take_card()
	if self._curcard then
		self:take_turn()
	end
end

function cls:call(idx, opcode, c, ... )
	-- body
	if opcode == opcode.hu then
		self:hu(idx, c)
	elseif opcode == opcode.peng then
		self:peng(idx, c)
	elseif opcode == opcode.gang then
		self:gang(idx, c)
	elseif opcode == opcode.guo then
		self:guo(idx)
	else
		assert(false)
	end
end

function cls:over( ... )
	-- body
	self._state = state.OVER
	self:clear_state(player.state.OVER)

	local args = {}
	local settle = {}
	for i=1,4 do
		local settlment = {}
		settlment.idx = i
		settlment.gold = 0
		table.insert(settle, settlment)
	end
	args.settle = settle

	self:push_client("over", args)
end

return cls