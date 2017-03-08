local skynet = require "skynet"
local card = require "card"
local player = require "player"
local log = require "log"
local list = require "list"
local util = require "util"
local errorcode = require "errorcode"
local opcode = require "opcode"
local hutype = require "hutype"
local jiaotype = require "jiaotype"
local region = require "region"
local multiple = require "multiple"
local exist = require "existhu"
local overtype = require "overtype"

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

state.CALL       = 9
state.PENG       = 10
state.GANG       = 11
state.HU         = 12

state.OVER       = 13

local cls = class("rcontext")

function cls:ctor( ... )
	-- body
	self._id = 0
	self._local = region.SICHUAN
	self._maxmultiple = 8
	self._overtype = overtype.XUEZHAN

	self._multiple = multiple(self._local, self._maxmultiple)
	self._exist = exist(self._local)

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
	
	self._state = state.NONE
	
	self._lastwin  = nil  -- last
	
	self._lastidx  = nil    -- last time lead from who
	self._lastcard = nil    -- last time lead card
	self._lastgantidx = nil -- last time gang

	self._firsttake = nil
	self._firstidx = nil
	self._curtake = nil
	self._curidx = nil  -- player
	self._curcard = nil
	
	self._takeround = 1

	self._countdown = 20 -- s

	self._call = {}
	self._callsz = 0
	self._waitcall = {}
	self._hus = {}

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
			if self:take_mcall() then
			else
				self:take_turn()
			end
		end
	elseif self._state == state.LEAD then
		local p = self._players[idx]
		assert(not p:get_noone())
		if self:check_state(idx, player.state.WAIT_TURN) then
			if self:take_ocall() then
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
			if self:take_mcall() then
			else
				self:take_turn()
			end
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
	if self._state == state.PENG then
		self._state = state.TURN
		self:clear_state(player.state.TURN)

		self._players[self._curidx]:timeout(self._countdown * 100)

		local args = {}
		args.your_turn = self._curidx
		args.countdown = self._countdown
		args.type = 0
		args.card = self._curcard:get_value()

		self:push_client("take_turn", args)
	elseif self._state == state.GANG then
		self._state = state.TURN
		self:clear_state(player.state.TURN)

		self._players[self._curidx]:timeout(self._countdown * 100)

		local args = {}
		args.your_turn = self._curidx
		args.countdown = self._countdown
		args.type = 0
		args.card = self._curcard:get_value()

		self:push_client("take_turn", args)
	else
		self._state = state.TURN
		self:clear_state(player.state.TURN)

		self._players[self._curidx]._holdcard = self._curcard
		self._players[self._curidx]:timeout(self._countdown * 100)

		local args = {}
		args.your_turn = self._curidx
		args.countdown = self._countdown
		args.type = 1
		args.card = self._curcard:get_value()

		self:push_client("take_turn", args)
	end
end

function cls:lead(idx, c, ... )
	-- body
	if self._state == state.TURN then
		self._state = state.LEAD

		assert(self._players[idx]._state == player.state.TURN)
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

function cls:take_mcall( ... )
	-- body
	local opcodes = {}
	local hucode = self._players[self._curidx]:check_hu(self._curcard)
	local gangcode = self._players[self._curidx]:check_gang(self._curcard)

	local huinfo = {}
	huinfo.idx  = self._curidx
	huinfo.card = self._curcard:get_value()
	huinfo.code = hucode
	huinfo.jiao = jiaotype.ZIMO
	huinfo.dian = self._curidx

	local opinfo = {}
	opinfo.idx = self._curidx
	opinfo.countdown = self._countdown
	opinfo.type = 1  -- take
	opinfo.card = self._curcard:get_value()
	opinfo.peng = opcode.none
	opinfo.gang = gangcode
	opinfo.hu = huinfo

	self._call[self._curidx] = {}
	self._waitcall[self._curidx] = {}
	local can = false
	if hucode ~= hutype.NONE then
		self._call[self._curidx].hu = true
		can = true
	end
	if gangcode ~= opcode.none then
		self._call[self._curidx].gang = true
		can = true
	end
	if can then
		self._state = state.CALL
		self:clear_state(player.state.CALL)

		self._players[self._curidx]:timeout(self._countdown * 100)
		table.insert(opcodes, opinfo)
		local args = {}
		args.opcodes = opcodes

		self:push_client("call", args)
		return true
	else
		return false
	end
end

function cls:take_ocall(opcodes, ... )
	-- body
	local opcodes = {}
	for i=1,4 do
		if self._curidx == i then
		else
			local hucode = self._players[i]:check_hu(self._lastcard)
			local gangcode = self._players[i]:check_gang(self._lastcard)
			local pengcode = self._players[i]:check_peng(self._lastcard)

			local huinfo = {}
			huinfo.idx  = i
			huinfo.card = self._lastcard:get_value()
			huinfo.code = hucode
			huinfo.dian = self._lastidx
			huinfo.jiao = jiaotype.NONE

			local opinfo = {}
			opinfo.idx = i
			opinfo.countdown = self._countdown
			opinfo.type = 0  -- take
			opinfo.card = 0
			opinfo.peng = pengcode
			opinfo.gang = gangcode
			opinfo.hu = huinfo

			self._call[self._curidx] = {}
			self._waitcall[self._curidx] = {}
			local can = false
			if hucode ~= hutype.NONE then
				self._call[i].hu = true
				can = true
			end
			if gangcode ~= opcode.none then
				self._call[i].gang = true
				can = true
			end
			if pengcode ~= opcode.none then
				self._call[i].peng = true
				can = true
			end
			if can then
				self._players[i]:timeout((self._countdown + 1) * 100)
				table.insert(opcodes, opinfo)
			end
		end
	end

	if #opcodes > 0 then	
		self._state = state.CALL
		self:clear_state(player.state.CALL)

		local args = {}
		args.opcodes = opcodes

		self:push_client("call", args)
		return true
	else
		return false
	end
	return res
end

function cls:peng(penginfo, ... )
	-- body
	assert(idx and c)
	if self._state == state.CALL then
		self._state = state.PENG
		assert(penginfo.idx ~= self._curidx)

		self._players[penginfo.idx]:peng(penginfo)
		self._curidx = idx

		self:push_client("peng", penginfo)
	end
end

function cls:gang(ganginfo, ... )
	-- body
	assert(idx and c)
	if self._state == state.CALL then
		self._state = state.GANG
		assert(ganginfo.code ~= opcode.none)
		if ganginfo.code == opcode.bugang then
			assert(ganginfo.idx == self._curidx)
			self._players[ganginfo.idx]:gang(ganginfo)
		elseif ganginfo.code == opcode.zhigang then
			self._players[ganginfo.idx]:gang(ganginfo)
			self._curidx = idx
			self:push_client("gang", ganginfo)
		elseif ganginfo.code == opcode.angang then
			self._players[idx]:gang(ganginfo)
			self._curidx = idx
			self:push_client("gang", ganginfo)
		else
			assert(false)
		end
	else
		log.info("player %d gang card %d", idx, c)
	end
end

function cls:hu(hus, ... )
	-- body
	assert(hus)
	if self._state == state.CALL then
		self._state = state.HU

		for k,v in pairs(hus) do
			assert(v.idx ~= self._curidx)
			if v.jiao == jiaotype.ZIMO then
				assert(self._players[v.idx]:check_hu(self._curcard))
				self._players[v.idx]:hu(self._curcard)
				self._curidx = v.idx
			else
				assert(self._players[v.idx]:check_hu(self._lastcard))
				self._players[v.idx]:hu(self._lastcard)
				self._curidx = v.idx
			end
		end

		local args = {}
		args.hus = hus
		self:push_client("hu", args)
	else
		log.info("player has hu")
	end
end

function cls:guo( ... )
	-- body
	if self._state == state.CALL then
		self._curidx = self:next_idx()
		self._curcard = self:take_card()
		if self._curcard then
			if self:take_mcall() then
			else
				self:take_turn()
			end
		else
			self:over()
		end
	end
end

function cls:call(opinfo, ... )
	-- body
	if self._state == state.CALL then
		local call = assert(self._call[idx])
		local waitcall = assert(self._waitcall[idx])
		if call.hu then
			assert(waitcall.hu == nil)
			assert(opinfo.hu)
			assert(opinfo.idx == opinfo.hu.idx)
			if opinfo.hu.code ~= hutype.NONE then
				waitcall.hu = opinfo.hu
				table.insert(self._hus, opinfo.hu)
				self._callsz = self._cardssz - 1
				if self._cardssz <= 0 then
					self:hu(self._hus)
				end
			end
		elseif call.gang then
			assert(waitcall.gang == nil)
			if opinfo.gang ~= opcode.none then
				waitcall.gang = {}
				waitcall.gang.idx = opinfo.idx
				waitcall.gang.card = opinfo.card
				waitcall.gang.code = opinfo.gang
				self._callsz = self._callsz - 1
				if self._callsz <= 0 then
					self:gang(waitcall.gang)
				end
			end
		elseif call.peng then
			assert(waitcall.peng == nil)
			if opinfo.peng ~= opcode.none then
				waitcall.peng = {}
				waitcall.peng.idx = opinfo.idx
				waitcall.peng.card = opinfo.card
				waitcall.peng.code = opinfo.gang
				self._callsz = self._callsz - 1
				if self._callsz <= 0 then
					self:peng(waitcall.peng)
				end
			end
		end
	else
		log.info("player %d timeout call", opinfo.idx)
	end
end

function cls:timeout_call(idx, ... )
	-- body
	if self._state == state.CALL then
		local call = assert(self._call[idx])
		local waitcall = assert(self._waitcall[idx])
		if call.hu then
			if waitcall.hu then
				if self._callsz <= 0 then
					self:hu(self._hus)
					return
				end
			else
				if self._players[idx]._hu.jiao == jiaotype.ZIMO then
					waitcall.hu = self._players[idx]._hu
					table.insert(self._hus, waitcall.hu)
					self._callsz = self._callsz - 1
					if self._callsz <= 0 then
						self:hu(self._hus)
						return
					end
				end
			end
		end
		if call.gang then
			if waitcall.gang then
				if self._callsz <= 0 then
					assert(false)
				end
			else
				self._callsz = self._callsz - 1
			end
		end
		if call.peng then
			if waitcall.peng then
				if self._callsz <= 0 then
					assert(false)
				end
			else
				self._callsz = self._callsz - 1
			end
		end
		if self._callsz <= 0 then
			self:guo()
		end
	else
		log.info("player %d timeout call", idx)
	end
end

function cls:take_over( ... )
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