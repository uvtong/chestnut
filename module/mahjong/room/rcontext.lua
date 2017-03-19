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
local cjson = require "cjson"

local state = {}
state.NONE       = 0
state.START      = 1
state.CREATE     = 2
state.JOIN       = 3
state.READY      = 4
state.SHUFFLE    = 5
state.DICE       = 6
state.XUANPAO    = 7
state.XUANQUE    = 8
state.TURN       = 9
state.LEAD       = 10

state.MCALL      = 11
state.OCALL      = 12
state.PENG       = 13
state.GANG       = 14
state.HU         = 15

state.OVER       = 16
state.RESTART    = 17

local cls = class("rcontext")

function cls:ctor( ... )
	-- body
	self._id = 0
	self._local = region.Sichuan
	self._overtype = overtype.XUEZHAN
	self._hujiaozhuanyi = false
	self._maxmultiple = 8
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
	self._countdown = 20 -- s

	self._state = state.NONE
	
	self._lastwin  = nil  -- last
	
	self._lastidx  = nil    -- last time lead from who
	self._lastcard = nil    -- last time lead card
	self._lastgantidx = nil -- last time gang

	self._firsttake = nil
	self._firstidx = nil    -- zhuangjia
	self._curtake = nil
	self._curidx = nil      -- player
	self._curcard = nil
	
	self._takeround = 1
	self._takeidx = 0
	
	self._call = {}
	self._callsz = 0
	self._callhu = 0
	self._callhux = 0
	self._callgang = 0
	self._callgangx = 0
	self._callpeng = 0
	self._callpengx = 0
	self._huinfos = {}
	self._ganginfo = nil 
	self._penginfo = nil

	self._stime = 0
	self._record = {}
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
	log.info("check player %d state", idx)
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

function cls:record(protocol, args, ... )
	-- body
	local tnode = {}
	tnode.protocol = protocol
	tnode.pt = (skynet.now() - _stime)
	tnode.args = args
	table.insert(self._record, tnode)
end

function cls:next_idx( ... )
	-- body
	self._curidx = self._curidx + 1
	if self._curidx > self._max then
		self._curidx = 1
	end
	return self._curidx
end

function cls:next_takeidx( ... )
	-- body
	self._curtake = self._curtake + 1
	if self._curtake > self._max then
		self._curtake = 1
	end
	return self._curtake
end

function cls:start(uid, args, ... )
	-- body
	assert(uid)
	self._host = uid
	if args.provice == region.Sichuan then
		self._local = region.Sichuan
		self._overtype = overtype.XUEZHAN
		self._maxmultiple = args.sc.top
		self._hujiaozhuanyi = args.sc.hujiaozhuanyi
		self._multiple = multiple(self._local, self._maxmultiple)
		self._exist = exist(self._local)

	elseif args.provice == region.Shaanxi then
		self._local = region.Shaanxi
		self._overtype = overtype.JIEHU
		self._maxmultiple = -1
		self._hujiaozhuanyi = false
		self._multiple = multiple(self._local, self._maxmultiple)
		self._exist = exist(self._local)
	end
end

function cls:take_card( ... )
	-- body
	local takep = self._players[self._curtake]
	if takep._takecardscnt > 0 then
		local card = takep:take_card()
		assert(card)
		self._takeidx = self._takeidx + 1
		return card
	else
		self._curtake = self:next_takeidx()
		if self._curtake == self._firsttake then
			assert(self._takeidx == self._cardssz)
			self:over()
		else
			takep = self._players[self._curtake]
			local card = takep:take_card()
			self._takeidx = self._takeidx + 1
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
			if self._local == region.Sichuan then
				self:take_xuanque()
			else
				if self:take_mcall() then
				else
					self:take_turn()
				end
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
	elseif self._state == state.HU then
		local p = self._players[idx]
		assert(not p:get_noone())
		if self:check_state(idx, player.state.WAIT_TURN) then
			self:over()
		end
	elseif self._state == state.OVER then
	elseif self._state == state.RESTART then
		local p = self._players[idx]
		assert(not p:get_noone())
		if self:check_state(idx, player.state.WAIT_TURN) then
			self:take_shuffle()
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
	self._takeround = 1
	self._takeidx = 0
	
	self._call = {}
	self._callsz = 0
	self._callhu = 0
	self._callhux = 0
	self._callgang = 0
	self._callgangx = 0
	self._callpeng = 0
	self._callpengx = 0
	self._huinfos = {}
	self._ganginfo = nil 
	self._penginfo = nil
	self._stime = skynet.now()
	self._record = {}
	
	self:record("shuffle", args)
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

	tnode.protocol = "dice"
	tnode.pt = (skynet.now() - self._stime)
	tnode.args = args
	table.insert(self._record, tnode)

	self:record("dice", args)
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

	self:record("deal", args)
	self:push_client("deal", args)
end

function cls:take_xuanpao( ... )
	-- body
	self._state = state.XUANPAO
	self:clear_state(player.state.XUANPAO)
	self:record("take_xuanpao")
	self:push_client("take_xuanpao")
end

function cls:xuanpao(args, ... )
	-- body
	assert(self._state == state.XUANPAO)
	self._players[args.idx]:set_fen(args.fen)
	self:record("take_xuanpao")
	self:push_client("xuanpao", args)
	if self:check_state(idx, player.state.WAIT_TURN) then
		self._curidx = self._firstidx -- reset curidx for turn 
		self._curcard = self:take_card()
		if self:take_mcall() then
		else
			self:take_turn()
		end
	end
end

function cls:take_xuanque( ... )
	-- body
	self._state = state.XUANQUE
	self:clear_state(player.state.XUANQUE)
	local args = {}
	args.countdown = self._countdown
	args.your_turn = self._curidx
	args.card = self._curcard:get_value()
	self:record("take_xuanque", args)
	self:push_client("take_xuanque", args)
end

function cls:xuanque(args, ... )
	-- body
	assert(self._state == state.XUANQUE)
	self._players[args.idx]:set_que(args.que)
	if self:check_state(idx, player.state.WAIT_TURN) then
		self:take_turn()
	end
end

function cls:take_turn( ... )
	-- body
	if self._state == state.PENG then
		self._state = state.TURN
		self:clear_state(player.state.TURN)

		local card = self._players[self._curidx]:take_turn_after_peng()
		self._players[self._curidx]:timeout(self._countdown * 100)

		local args = {}
		args.your_turn = self._curidx
		args.countdown = self._countdown
		args.type = 0
		args.card = card:get_value()

		self:record("take_turn", args)
		self:push_client("take_turn", args)
	elseif self._state == state.GANG then
		self._state = state.TURN
		self:clear_state(player.state.TURN)

		self._players[self._curidx]:timeout(self._countdown * 100)

		local args = {}
		args.your_turn = self._curidx
		args.countdown = self._countdown
		args.type = 1
		args.card = self._curcard:get_value()

		self:record("take_turn", args)
		self:push_client("take_turn", args)
	elseif self._state == state.MCALL or
		self._state == state.XUANQUE then
		self._state = state.TURN
		self:clear_state(player.state.TURN)

		assert(self._players[self._curidx]._holdcard)
		self._players[self._curidx]:timeout(self._countdown * 100)

		local args = {}
		args.your_turn = self._curidx
		args.countdown = self._countdown
		args.type = 0
		args.card = 0

		self:record("take_turn", args)
		self:push_client("take_turn", args)
	else
		self._state = state.TURN
		self:clear_state(player.state.TURN)

		self._players[self._curidx]._holdcard = assert(self._curcard)
		self._players[self._curidx]:timeout(self._countdown * 100)

		local args = {}
		args.your_turn = self._curidx
		args.countdown = self._countdown
		args.type = 1
		args.card = self._curcard:get_value()

		self:record("take_turn", args)
		self:push_client("take_turn", args)
	end
end

function cls:lead(idx, c, ... )
	-- body
	assert(idx and c)
	if self._state == state.TURN then
		self._state = state.LEAD

		assert(self._players[idx]._state == player.state.TURN)
		self._players[idx]:cancel_timeout()
		
		local card = self._players[idx]:lead(c)
		assert(card:get_value() == c)
		log.info("player %d lead %s", idx, card:describe())

		self._lastidx = idx
		self._lastcard = card
		self._curidx = idx
		local args = {}
		args.idx = idx
		args.card = c

		self:record("lead", args)
		self:push_client("lead", args)
	else
		log.info("player %d has leaded", idx)
	end
end

function cls:take_mcall( ... )
	-- body
	log.info("player %d take my call", self._curidx)
	self._call = {}
	self._huinfos = {}
	self._ganginfo = nil
	self._penginfo = nil

	local opcodes = {}
	local hucode = self._players[self._curidx]:check_hu(self._curcard, jiaotype.ZIMO, self._curidx)
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
	opinfo.card = self._curcard:get_value()
	opinfo.peng = opcode.none
	opinfo.gang = gangcode
	opinfo.hu = huinfo

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

		self._state = state.MCALL
		self:clear_state(player.state.MCALL)

		self._players[self._curidx]:timeout((self._countdown + 1) * 100)
		table.insert(opcodes, opinfo)
		local args = {}
		args.opcodes = opcodes

		self:record("call", args)
		self:push_client("call", args)
		return true
	else
		return false
	end
end

function cls:take_ocall( ... )
	-- body
	
	self._call = {}
	self._callsz = 0
	self._callhu = 0
	self._callhux = 0
	self._callgang = 0
	self._callgangx = 0
	self._callpeng = 0
	self._callpengx = 0
	self._huinfos = {}
	self._ganginfo = nil
	self._penginfo = nil

	local opcodes = {}
	for j=1,4 do
		local i = self._curidx + j
		i = (i > 4) and (i - 4) or i
		if self._curidx == i then
		else
			assert(self._lastcard)
			local hucode = self._players[i]:check_hu(self._lastcard, jiaotype.NONE, self._lastidx)
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
			opinfo.card = self._lastcard:get_value()
			opinfo.peng = pengcode
			opinfo.gang = gangcode
			opinfo.hu = huinfo

			self._call[i] = {}
			local can = false
			if hucode ~= hutype.NONE then
				self._call[i].hu = true
				self._callhu = self._callhu + 1
				self._callhux = self._callhux + 1
				can = true
			end
			if gangcode ~= opcode.none then
				self._call[i].gang = true
				self._callgang = self._callgang + 1
				self._callgangx = self._callgangx + 1
				can = true
			end
			if pengcode ~= opcode.none then
				self._call[i].peng = true
				self._callpeng = self._callpeng + 1
				self._callpengx = self._callpengx + 1
				can = true
			end
			if can then
				self._callsz = self._callsz + 1
				self._players[i]:timeout((self._countdown + 1) * 100)
				table.insert(opcodes, opinfo)
			end
		end
	end

	if #opcodes > 0 then	
		self._state = state.OCALL
		self:clear_state(player.state.OCALL)

		local args = {}
		args.opcodes = opcodes

		self:record("call", args)
		self:push_client("call", args)
		return true
	else
		return false
	end
end

function cls:peng(penginfo, ... )
	-- body
	assert(penginfo)
	if self._state == state.OCALL then
		self._state = state.PENG
		assert(penginfo.idx ~= self._curidx)
		self._curidx = penginfo.idx
		local res = self._players[penginfo.idx]:peng(penginfo)
		penginfo.hor = res.hor

		self:record("peng", penginfo)
		self:push_client("peng", penginfo)
	end
end

function cls:gang(ganginfo, ... )
	-- body
	assert(ganginfo)
	if self._state == state.MCALL then
		assert(ganginfo.idx == self._curidx)
		self._state = state.GANG

		if ganginfo.code == opcode.bugang then
			self._players[ganginfo.idx]:gang(ganginfo)

			self:record("gang", ganginfo)
			self:push_client("gang", ganginfo)
		elseif ganginfo.code == opcode.angang then
			self._players[idx]:gang(ganginfo)

			self:record("gang", ganginfo)
			self:push_client("gang", ganginfo)
		else
			assert(false)
		end
	elseif self._state == state.OCALL then
		assert(ganginfo.idx ~= self._curidx)
		self._state = state.GANG
		
		if ganginfo.code == opcode.zhigang then
			self._curidx = ganginfo.idx

			local res = self._players[ganginfo.idx]:gang(ganginfo)
			ganginfo.hor = res.hor

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
	if self._state == state.MCALL then
		assert(#hus == 1)

		self._state = state.HU
		self._players[v.idx]:hu(hus[1])

		local args = {}
		args.hus = hus
		self:push_client("hu", args)
	elseif self._state == state.OCALL then
		self._state = state.HU

		for k,v in pairs(hus) do
			self._players[v.idx]:hu(v)
			self._curidx = v.idx
		end

		local args = {}
		args.hus = hus
		self:push_client("hu", args)
	else
		log.info("player has hu")
	end
end

function cls:_next( ... )
	-- body
	self._curidx = self:next_idx()
	self._curcard = self:take_card()
	if self._curcard then
		if self:take_mcall() then
		else
			self:take_turn()
		end
	else
		self._state = state.OVER
		self:take_over()
	end
end

function cls:guo( ... )
	-- body
	if self._state == state.MCALL then
		self:take_turn()
	elseif self._state == state.LEAD then
		self:_next()
	elseif self._state == state.OCALL then
		self:_next()
	else
		assert(false)
	end
end

function cls:_calc_call( ... )
	-- body
	if self._callhu > 0 then -- first
		if self._callhux <= 0 then
			if #self._hus > 0 then
				self:hu(self._hus)
			else
				if self._callgang > 0 then
					if self._callgangx <= 0 then
						if self._ganginfo then
							self:gang(self._ganginfo)
						else
							self:guo()
						end
					else
					end
				elseif self._callpeng > 0 then
					if self._callpengx <= 0 then
						if self._penginfo then
							self:peng(self._penginfo)
						else
							self:guo()
						end
					else
					end
				end
			end
		else
		end
	else
		if self._callgang > 0 then
			if self._callgangx <= 0 then
				if self._ganginfo then
					self:gang(self._ganginfo)
				else
					self:guo()
				end
			else
			end
		elseif self._callpeng > 0 then
			if self._callpengx <= 0 then
				if self._penginfo then
					self:peng(self._penginfo)
				else
					self:guo()
				end
			else
			end
		end
	end	
end

function cls:call(opinfo, ... )
	-- body
	local call = assert(self._call[opinfo.idx])
	if self._state == state.MCALL then
		assert(self._curidx == opinfo.idx)
		self._players[opinfo.idx]:cancel_timeout()
		if opinfo.guo == opcode.guo then
			self:guo()
		elseif opinfo.hu.code ~= huinfo.NONE then
			local hu = {}
			hu.idx = opinfo.idx
			hu.card = opinfo.card
			hu.code = opinfo.hu.code
			hu.jiao = opinfo.hu.jiao
			hu.dian = opinfo.hu.dian
			table.insert(self._huinfos, hu)
			self:hu(self._huinfos)
		elseif opinfo.gang ~= opcode.none then
			assert(call.gang)
			local gang = {}
			gang.idx = opinfo.idx
			gang.card = opinfo.card
			gang.code = opinfo.gang
			self:gang(gang)
		else
			assert(false)
		end
	elseif self._state == state.OCALL then
		self._callsz = self._callsz - 1
		self._players[opinfo.idx]:cancel_timeout()
		if call.hu then
			if opinfo.hu.code ~= hutype.NONE then -- selected
				local hu = {}
				hu.idx = opinfo.idx
				hu.card = opinfo.card
				hu.code = opinfo.hu.code
				hu.jiao = opinfo.hu.jiao
				hu.dian = opinfo.hu.dian
				table.insert(self._huinfos, hu)
			end
			self._callhux = self._callhux - 1
		end
		if call.gang then
			if opinfo.gang ~= opcode.none then
				local gang = {}
				gang.idx = opinfo.idx
				gang.card = opinfo.card
				gang.code = opinfo.gang
				self._ganginfo = gang
			end
			self._callgangx = self._callgangx - 1
		end
		if call.peng then
			if opinfo.peng ~= opcode.none then
				local peng = {}
				peng.idx = opinfo.idx
				peng.card = opinfo.card
				peng.code = opinfo.peng
				self._penginfo = peng
			end
			self._callpengx = self._callpengx - 1
		end
		self:_calc_call()
	else
		log.info("player %d timeout call", opinfo.idx)
	end
end

function cls:timeout_call(idx, ... )
	-- body
	local call = assert(self._call[idx])
	if self._state == state.MCALL then
		if call.hu then -- only 1
			local hu = {}
			hu.idx = self._players[idx]._hu.idx
			hu.card = self._players[idx]._hu.card:get_value()
			hu.code = self._players[idx]._hu.code
			hu.jiao = self._players[idx]._hu.jiao
			hu.dian = self._players[idx]._hu.dian
			table.insert(self._huinfos, hu)
			self:hu(self._hus)
			return
		end
		if call.gang then
			self:guo()
			return
		end
	elseif self._state == state.OCALL then
		self._callsz = self._callsz - 1
		if call.hu then -- only 1
			self._callhux = self._callhux - 1
		end
		if call.gang then
			self._callgangx = self._callgangx - 1
		end
		if call.peng then
			self._callpengx = self._callpengx - 1
		end
		self:_calc_call()
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

function cls:restart(idx, ... )
	-- body
	if self._state == state.OVER then
		local p = self._players[idx]
		assert(not p:get_noone())
		if self:check_state(idx, player.state.WAIT_RESTART) then
			self:take_restart()
		else
			local args = {}
			args.idx = idx
			self:push_client("restart", args)
		end
	end
end

function cls:take_restart( ... )
	-- body
	self._state = state.RESTART
	self:clear_state(player.state.RESTART)

	self:push_client("take_restart")
end

function cls:chat(args, ... )
	-- body
	if self._state >= state.READY and self._state < state.OVER then
		self:push_client("rchat", args)
	end
end

return cls