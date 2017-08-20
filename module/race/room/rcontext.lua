local skynet = require "skynet"
local log = require "skynet.log"
local card = require "card"
local player = require "player"
local list = require "list"
local util = require "util"
local errorcode = require "errorcode"
local opcode = require "opcode"
local hutype = require "hutype"
local jiaotype = require "jiaotype"
local region = require "region"
local humultiple = require "humultiple"
local exist = require "existhu"
local overtype = require "overtype"
local cjson = require "cjson"
local gangmultiple = require "gangmultiple"
local context = require "context"

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
state.SETTLE     = 17
state.FINAL_SETTLE = 18
state.RESTART    = 19

local cls = class("rcontext", context)

function cls:ctor( ... )
	-- body
	self._id = 0
	self._host = nil
	self._open = false

	-- config
	self._local = region.Sichuan
	self._overtype = overtype.XUEZHAN
	self._maxmultiple = 8
	self._humultiple = humultiple(self._local, self._maxmultiple)
	self._exist = exist(self._local)
	self._hujiaozhuanyi = false
	self._zimo = 0
	self._dianganghua = 0
	self._daiyaojiu = 0
	self._duanyaojiu = 0
	self._jiangdui = 0
	self._tiandihu = 0
	self._maxju = 0

	self._players = {}
	for i=1,4 do
		local tmp = player.new(self)
		tmp._idx = i
		self._players[i] = tmp
	end
	self._max = 4
	self._joined = 0
	self._online = 0

	self._cards = {}
	self._cardssz = 108
	self:init_cards()

	self._countdown = 20 -- s

	self._state = state.NONE	
	self._lastfirsthu  = 0    -- last,make next zhuangjia
	
	self._lastidx  = 0    -- last time lead from who
	self._lastcard = nil    -- last time lead card

	self._firsttake = 0
	self._firstidx  = 0    -- zhuangjia
	self._curtake   = 0
	self._curidx    = 0      -- player
	self._curcard = nil
	
	self._takeround = 1
	self._takeidx = 0       -- count
	
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

	self._ju = 0
	self._leadaftergang = false
	
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

function cls:clear( ... )
	-- body
	for i=1,4 do
		self._players[i]:set_noone(true)
		self._players[i]:set_online(false)
	end
	self._joined = 0
	self._online = 0
end

function cls:find_noone( ... )
	-- body
	if self._joined >= self._max then
		return false
	end
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
	for i=1,self._max do
		if self._players[i]._state ~= state then
			return false
		end
	end
	return true
end

function cls:check_over( ... )
	-- body
	if self._overtype == overtype.JIEHU then
		local count = 0
		for i=1,self._max do
			if self._players[i]:hashu() then
				count = count + 1
			end
		end
		if count >= 1 then
			return true
		end
	elseif self._overtype == overtype.XUEZHAN then
		local count = 0
		for i=1,self._max do
			if self._players[i]:hashu() then
				count = count + 1
			end
		end
		if count >= 3 then
			return true
		end
	elseif self._overtype == overtype.XUELIU then
	end		
	if self._takeidx == self._cardssz then
		return true
	end
	return false
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
		assert(p:get_noone() == false)
		if p:get_online() then
			skynet.send(p._agent, "lua", name, args)
		else
			while true do
				skynet.sleep(100 * 2) -- 10s
				if p:get_online() then
					skynet.send(p._agent, "lua", name, args)
					break
				end		
			end
		end
	end
end

function cls:push_client_idx(idx, name, args, ... )
	-- body
	local p = self._players[idx]
	if not p._noone then
		skynet.send(p._agent, "lua", name, args)
	end
end

function cls:record(protocol, args, ... )
	-- body
	local tnode = {}
	tnode.protocol = protocol
	tnode.pt = (skynet.now() - self._stime)
	tnode.args = args
	table.insert(self._record, tnode)
end

function cls:next_idx( ... )
	-- body
	if self._overtype == overtype.JIEHU then
		self._curidx = self._curidx + 1
		if self._curidx > self._max then
			self._curidx = 1
		end
		return self._curidx
	elseif self._overtype == overtype.XUEZHAN then
		self._curidx = self._curidx + 1
		if self._curidx > self._max then
			self._curidx = 1
		end
		while self._players[self._curidx]:hashu() do
			self._curidx = self._curidx + 1
			if self._curidx > self._max then
				self._curidx = 1
			end
		end
		return self._curidx
	elseif self._overtype == overtype.XUELIU then
		self._curidx = self._curidx + 1
		if self._curidx > self._max then
			self._curidx = 1
		end
		return self._curidx
	end
end

function cls:next_takeidx( ... )
	-- body
	self._curtake = self._curtake - 1
	if self._curtake <= 0 then
		self._curtake = self._max
	end
	return self._curtake
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
		assert(self._curtake == self._firsttake)
	end
end

function cls:start(uid, args, ... )
	-- body
	assert(uid)
	self._host = uid
	self._open = true
	if args.provice == region.Sichuan then
		self._local = region.Sichuan
		self._overtype = args.overtype
		self._maxmultiple = args.sc.top
		self._hujiaozhuanyi = args.sc.hujiaozhuanyi
		self._humultiple = humultiple(self._local, self._maxmultiple)
		self._exist = exist(self._local)
		self._maxju = args.ju

	elseif args.provice == region.Shaanxi then
		self._local = region.Shaanxi
		self._overtype = args.overtype
		self._maxmultiple = -1
		self._hujiaozhuanyi = false
		self._humultiple = humultiple(self._local, self._maxmultiple)
		self._exist = exist(self._local)
		self._maxju = args.ju
	end
	self:clear()
	local res = {}
	res.errorcode = errorcode.SUCCESS
	res.roomid = self._id
	res.room_max = self._max
	return res
end

function cls:close( ... )
	-- body
	self._open = false
	return true
end

function cls:authed(uid, ... )
	-- body
	local p = self:get_player_by_uid(uid)
	assert(p)
	p:set_online(true)
	self:incre_online()

	for i=1,self._max do
		if i == p:get_idx() then
		else
			local args = {}
			args.idx = i
			self:push_client_idx(i, "afk", args)
		end
	end
end

function cls:afk(uid, ... )
	-- body
	local p = self:get_player_by_uid(uid)
	assert(p)
	p:set_online(false)
	self:decre_online()

	for i=1,self._max do
		if i == p:get_idx() then
		else
			local args = {}
			args.idx = i
			self:push_client_idx(i, "afk", args)
		end
	end

	return true
end

function cls:join(uid, sid, agent, name, sex, ... )
	-- body
	local res = {}
	self._state = state.JOIN
	if self._joined >= self._max then
		res.errorcode = errorcode.ROOM_FULL
		return res
	end
	local me = assert(self:find_noone())
	me:set_uid(uid)
	me:set_sid(sid)
	me:set_agent(agent)
	me:set_name(name)
	me:set_sex(sex)
	me:set_noone(false)
	me:set_online(true)
	self._joined = self._joined + 1
	self:incre_online()

	local p = {
		idx = me:get_idx(),
		chip = me:get_chip(),
		sid = me:get_sid(),
		sex = me:get_sex(),
		name = me:get_name(),
	}

	local args = {}
	args.p = p
	for k,v in pairs(self._players) do
		if not v._noone and v ~= me then
			self:push_client_idx(v:get_idx(), "join", args)
		end
	end

	res.errorcode = errorcode.SUCCESS
	res.roomid = self._id
	res.room_max = self._max
	res.me = p
	local ps = {}
	for i,v in ipairs(self._players) do
		if not v:get_noone() and v:get_uid() ~= uid then
			local p = {
				idx  = v:get_idx(),
				chip = v:get_chip(),
				sid  = v:get_sid(),
				sex  = v:get_sex(),
				name = v:get_name(),
			}
			table.insert(ps, p)
		end
	end
	res.ps = ps
	return res
end

function cls:leave(idx, ... )
	-- body
	local p = self._players[idx]
	assert(p)
	if self._players[idx]:get_uid() == self._host then
		for i=1,self._max do
			if i == idx then
			else
				local args = {}
				args.idx = idx
				if not self._players[i]:get_noone() then
					skynet.send(self._players[i]:get_agent(), "lua", "exit_room", args)
				end
			end
			self._players[i]:set_noone(true)
		end
		skynet.call(".ROOM_MGR", "lua", "enqueue_room", self._id)
	else
		for i=1,self._max do
			if i == idx then
			else
				local args = {}
				args.idx = idx
				if self._players[i]:get_online() then
					self:push_client_idx(i, "leave", args)
				end
			end
		end
		p:set_noone(true)
		p:set_online(false)
		self._joined = self._joined - 1
		self:decre_online()

	end

	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
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
			self._players[self._curidx]:take_turn_card(self._curcard)
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
			if self:check_over() then
				self:take_over()
			else
				if self._players[self._curidx]._gang.code == opcode.bugang then
					if self:take_ocall() then
					else
						self._curcard = self:take_card()
						if not self._curcard then
							self:take_over()
						else
							self._players[self._curidx]:take_turn_card(self._curcard)
							if self:take_mcall() then
							else
								self:take_turn()
							end
						end
					end
				else
					self._curcard = self:take_card()
					if not self._curcard then
						self:take_over()
					else
						self._players[self._curidx]:take_turn_card(self._curcard)
						if self:take_mcall() then
						else
							self:take_turn()
						end
					end
				end
			end
		end
	elseif self._state == state.HU then
		local p = self._players[idx]
		assert(not p:get_noone())
		if self:check_state(idx, player.state.WAIT_TURN) then
			if self:check_over() then
				self:take_over() 
			else
				self._curidx = self:next_idx()
				self._curcard = self:take_card()
				self._players[self._curidx]:take_turn_card(self._curcard)
				if self:take_mcall() then
				else
					self:take_turn()
				end
			end
		end
	elseif self._state == state.OVER then
		local p = self._players[idx]
		assert(not p:get_noone())
		if self:check_state(idx, player.state.WAIT_TURN) then
			self:take_settle()
		end
	elseif self._state == state.SETTLE then
		local p = self._players[idx]
		assert(not p:get_noone())
		if self:check_state(idx, player.state.WAIT_TURN) then
			self:take_final_settle()	
		end		
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

	self._ju = self._ju + 1
	if self._ju == 1 then
		-- send agent 
		local p = self:get_player_by_uid(self._host)
		local addr = p:get_agent()
		skynet.call(addr, "lua", "alter_rcard", -1)
	end

	self._stime = skynet.now()
	self._record = {}
	-- record 
	local args = {}
	for i=1,self._max do
		local p = {}
		p.idx = self._players[i]:get_idx()
		p.uid = self._players[i]:get_uid()
		table.insert(args, p)
	end
	self:record("players", args)

	if self._lastfirsthu == 0 then
		self._firstidx = self:get_player_by_uid(self._host):get_idx()
	else
		self._firstidx = self._lastfirsthu
	end
	self._curidx = self._firstidx

	for i=1,self._cardssz do
		self._cards[i]:clear()
	end

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
	args.first = self._firstidx

	self:record("shuffle", args)
	self:push_client("shuffle", args)
end

function cls:take_dice( ... )
	-- body
	self._state = state.DICE
	local d1 = math.random(0, 5) + 1
	local d2 = math.random(0, 5) + 1
	local min = math.min(d1, d2)
	local point = d1 + d2
	while point > self._max do
		point = point - self._max
	end
	assert(point > 0 and point <= self._max)

	self._firsttake = point
	self._curtake   = point

	self._takeround = 1
	local takep = self._players[self._curtake]
	takep._takecardsidx = (min * 2 + 1)

	local args = {}
	args.first     = self._firstidx
	args.firsttake = self._firsttake
	args.d1 = d1
	args.d2 = d2

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
	args.firstidx  = self._firstidx
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

	for i=1,self._max do
		self._players[i]:timeout(self._countdown * 100)
	end

	local args = {}
	args.countdown = self._countdown
	args.your_turn = self._curidx
	args.card = self._curcard:get_value()
	self:record("take_xuanque", args)
	self:push_client("take_xuanque", args)
end

function cls:xuanque(args, ... )
	-- body
	if self._state == state.XUANQUE then
		if self._players[args.idx]._state == player.state.XUANQUE then
			self._players[args.idx]:cancel_timeout()
			self._players[args.idx]:set_que(args.que)
			self:record("xuanque", args)
			self:push_client("xuanque", args)
			if self:check_state(args.idx, player.state.WAIT_TURN) then
				self:take_turn()
			end
		end
	end
end

function cls:timeout_xuanque(args, ... )
	-- body
	assert(self._state == state.XUANQUE)
	if self._players[args.idx]._state == player.state.XUANQUE then
		self._players[args.idx]:set_que(args.que)
		self:push_client("xuanque", args)
		if self:check_state(args.idx, player.state.WAIT_TURN) then
			self:take_turn()
		end
	end	
end

function cls:take_turn( ... )
	-- body
	if self._state == state.PENG then
		self._state = state.TURN
		self:clear_state(player.state.TURN)
		self._leadaftergang = false

		local card = self._players[self._curidx]:take_turn_after_peng()
		assert(self._players[self._curidx]._holdcard)
		self._players[self._curidx]:timeout(self._countdown * 100)

		local args = {}
		args.your_turn = self._curidx
		args.countdown = self._countdown
		args.type = 0
		args.card = card:get_value()

		log.info("player %d take turn, turn type:%d", self._curidx, 0)
		-- self:record("take_turn", args)
		self:push_client("take_turn", args)
	elseif self._state == state.GANG then
		self._state = state.TURN
		self:clear_state(player.state.TURN)
		self._leadaftergang = true

		assert(self._players[self._curidx]._holdcard)
		self._players[self._curidx]:timeout(self._countdown * 100)

		local args = {}
		args.your_turn = self._curidx
		args.countdown = self._countdown
		args.type = 1
		args.card = self._curcard:get_value()

		log.info("player %d take turn, turn type:%d", self._curidx, 1)
		-- self:record("take_turn", args)
		self:push_client("take_turn", args)
	elseif self._state == state.MCALL then
		self._state = state.TURN
		self:clear_state(player.state.TURN)
		self._leadaftergang = false

		assert(self._players[self._curidx]._holdcard)
		self._players[self._curidx]:timeout(self._countdown * 100)

		local args = {}
		args.your_turn = self._curidx
		args.countdown = self._countdown
		args.type = 3
		args.card = self._curcard:get_value()

		log.info("player %d take turn, turn type:%d", self._curidx, 3)
		-- self:record("take_turn", args)
		self:push_client("take_turn", args)
		
	elseif self._state == state.XUANQUE then
		self._state = state.TURN
		self:clear_state(player.state.TURN)
		self._leadaftergang = false

		assert(self._players[self._curidx]._holdcard)
		self._players[self._curidx]:timeout(self._countdown * 100)

		local args = {}
		args.your_turn = self._curidx
		args.countdown = self._countdown
		args.type = 2
		args.card = 0

		log.info("player %d take turn, turn type:%d", self._curidx, 2)
		-- self:record("take_turn", args)
		self:push_client("take_turn", args)
	else
		self._state = state.TURN
		self:clear_state(player.state.TURN)
		self._leadaftergang = false

		assert(self._players[self._curidx]._holdcard)
		self._players[self._curidx]:timeout(self._countdown * 100)

		local args = {}
		args.your_turn = self._curidx
		args.countdown = self._countdown
		args.type = 1
		args.card = self._curcard:get_value()

		log.info("player %d take turn, turn type:%d", self._curidx, 1)
		-- self:record("take_turn", args)
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
		card:clear()

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

	log.info("take my call player %d check_hu", self._curidx)
	local reshu
	if self._state == state.GANG then
		if self._players[self._curidx]._gang.code == opcode.zhigang then
			reshu = self._players[self._curidx]:check_hu(self._curcard, jiaotype.DIANGANGHUA, self._curidx)
		elseif self._players[self._curidx]._gang.code == opcode.angang then
			reshu = self._players[self._curidx]:check_hu(self._curcard, jiaotype.ZIGANGHUA, self._curidx)
		elseif self._players[self._curidx]._gang.code == opcode.bugang then
			reshu = self._players[self._curidx]:check_hu(self._curcard, jiaotype.ZIGANGHUA, self._curidx)
		else
			assert(false)
		end
	else
		reshu = self._players[self._curidx]:check_hu(self._curcard, jiaotype.ZIMO, self._curidx)
	end
	log.info("take my call player %d check_gang", self._curidx)

	local resgang
	if self._overtype == overtype.XUELIU and self._players[self._curidx]:hashu() then
		resgang = self._players[self._curidx]:check_xueliu_gang(self._curcard, self._curidx)
	else
		resgang = self._players[self._curidx]:check_gang(self._curcard, self._curidx)
	end

	local huinfo = {}
	huinfo.idx  = reshu.idx
	huinfo.card = reshu.card:get_value()
	huinfo.code = reshu.code
	huinfo.jiao = reshu.jiao
	huinfo.dian = reshu.dian
	huinfo.gang = reshu.gang

	local opinfo = {}
	opinfo.idx = self._curidx
	opinfo.countdown = self._countdown
	opinfo.take = self._curcard:get_value()
	opinfo.card = resgang.card:get_value()
	opinfo.dian = resgang.dian
	opinfo.peng = opcode.none
	opinfo.gang = resgang.code
	opinfo.hu = huinfo

	self._call[self._curidx] = {}
	local can = false
	if opinfo.hu.code ~= hutype.NONE then
		log.info("take my call player %d call hu code: %d", self._curidx, opinfo.hu.code)

		self._call[self._curidx].hu = true
		self._callhu = self._callhu + 1
		self._callhux = self._callhu
		can = true
	end
	if opinfo.gang ~= opcode.none then
		log.info("take my call player %d call gang code: %d", self._curidx, opinfo.gang)

		self._call[self._curidx].gang = true
		self._callgang = self._callgang + 1
		self._callgangx = self._callgang
		can = true
	end
	if can then
		self._state = state.MCALL
		self:clear_state(player.state.MCALL)

		self._callsz = self._callsz + 1
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
	assert(self._lastcard and self._lastidx)

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
	for j=1,self._max do
		local i = self._curidx + j
		if i > self._max then
			i = i - self._max
		end

		if self._curidx == i then
		elseif self._overtype == overtype.XUEZHAN and self._players[i]:hashu() then
		else
			local reshu
			local resgang
			local respeng
			if self._state == state.GANG then
				reshu = self._players[i]:check_hu(self._players[self._curidx]._gang.card, jiaotype.QIANGGANGHU, self._curidx)
			else
				log.info("take other call player %d check_hu", i)
				if self._leadaftergang then
					reshu = self._players[i]:check_hu(self._lastcard, jiaotype.GANGSHANGPAO, self._lastidx)
				else
					reshu = self._players[i]:check_hu(self._lastcard, jiaotype.PINGFANG, self._lastidx)
				end
				log.info("take other call player %d check_gang", i)
				if self._overtype == overtype.XUELIU and self._players[i]:hashu() then
					resgang = self._players[i]:check_xueliu_gang(self._lastcard, self._lastidx)
				else
					resgang = self._players[i]:check_gang(self._lastcard, self._lastidx)
					
					log.info("take other call player %d check_peng", i)
					respeng = self._players[i]:check_peng(self._lastcard, self._lastidx)	
				end
			end

			local huinfo = {}
			huinfo.idx  = reshu.idx
			huinfo.card = reshu.card:get_value()
			huinfo.code = reshu.code
			huinfo.gang = reshu.gang
			huinfo.dian = reshu.dian
			huinfo.jiao = reshu.jiao

			local opinfo = {}
			opinfo.idx = i
			opinfo.countdown = self._countdown
			opinfo.take = self._curcard:get_value()
			if resgang and resgang.code ~= opcode.none then
				opinfo.card = resgang.card:get_value()
				opinfo.dian = resgang.dian
				opinfo.gang = resgang.code
				opinfo.peng = opcode.none
			elseif respeng and respeng.code ~= opcode.none then
				opinfo.card = respeng.card:get_value()
				opinfo.dian = respeng.dian
				opinfo.gang = opcode.none
				opinfo.peng = respeng.code
			else
				opinfo.card = self._lastcard:get_value()
				opinfo.dian = self._lastidx
				opinfo.peng = opcode.none
				opinfo.gang = opcode.none
			end
			opinfo.hu = huinfo

			self._call[i] = {}
			local can = false
			if opinfo.hu.code ~= hutype.NONE then
				log.info("take other call player %d call hu code: %d", i, opinfo.hu.code)
				self._call[i].hu = true
				self._callhu = self._callhu + 1
				self._callhux = self._callhux + 1
				can = true
			end
			if opinfo.gang ~= opcode.none then
				log.info("take other call player %d call gang code: %d", i, opinfo.gang)
				self._call[i].gang = true
				self._callgang = self._callgang + 1
				self._callgangx = self._callgangx + 1
				can = true
			end
			if opinfo.peng ~= opcode.none then
				log.info("take other call player %d call peng code: %d", i, opinfo.peng)

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
	log.info("player peng")
	assert(penginfo)
	if self._state == state.OCALL then
		self._state = state.PENG
		assert(penginfo.idx ~= self._curidx)
		self._curidx = penginfo.idx
		local res = self._players[penginfo.idx]:peng(penginfo, self._players[self._lastidx], self._lastcard)
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
			self._players[ganginfo.idx]:gang(ganginfo, self._players[self._lastidx], self._lastcard)
			local base = gangmultiple(opcode.bugang)
			local total = 0
			local lose = {}
			local win = {ganginfo.idx}
			local settle = {}
			for i=1,self._max do
				if i == ganginfo.idx then
				elseif self._players[i]:hashu() then
				else
					total = total + base
					table.insert(lose, i)

					local cnode = {}
					cnode.idx  = i
					cnode.chip = -base
					cnode.left = self._players[i]:settle(cnode.chip)

					cnode.win  = win
					cnode.lose = lose
					cnode.gang = ganginfo.code
					cnode.hucode = hutype.NONE
					cnode.hujiao = jiaotype.NONE
					cnode.huazhu = 0
					cnode.dajiao = 0
					cnode.tuisui = 0

					self:insert_settle(settle, cnode.idx, cnode)
					self._players[i]:record_settle(cnode)
				end
			end

			local cnode = {}
			cnode.idx  = ganginfo.idx
			cnode.chip = total
			cnode.left = self._players[ganginfo.idx]:settle(cnode.chip)

			cnode.win  = win
			cnode.lose = lose
			cnode.gang = ganginfo.code
			cnode.hucode = hutype.NONE
			cnode.huazhu = 0
			cnode.dajiao = 0
			cnode.tuisui = 0
			self:insert_settle(settle, cnode.idx, cnode)
			self._players[ganginfo.idx]:record_settle(cnode)

			local settles = {}
			table.insert(settles, settle)
			ganginfo.settles = settles
			self:record("gang", ganginfo)
			self:push_client("gang", ganginfo)
		elseif ganginfo.code == opcode.angang then
			self._players[ganginfo.idx]:gang(ganginfo, self._players[self._lastidx], self._lastcard)
			local base = gangmultiple(opcode.angang)
			local total = 0
			local lose = {}
			local win = {ganginfo.idx}
			local settle = {}
			for i=1,self._max do
				if i == ganginfo.idx then
				elseif self._players[i]:hashu() then
				else
					total = total + base
					table.insert(lose, i)

					local cnode = {}
					cnode.idx  = i
					cnode.chip = -base
					cnode.left = self._players[i]:settle(cnode.chip)

					cnode.win  = win
					cnode.lose = lose
					cnode.gang = ganginfo.code
					cnode.hucode = hutype.NONE
					cnode.huazhu = 0
					cnode.dajiao = 0
					cnode.tuisui = 0

					self:insert_settle(settle, cnode.idx, cnode)
					self._players[i]:record_settle(cnode)
				end
			end

			local cnode = {}
			cnode.idx  = ganginfo.idx
			cnode.chip = total
			cnode.left = self._players[ganginfo.idx]:settle(cnode.chip)

			cnode.win  = win
			cnode.lose = lose

			cnode.gang = ganginfo.code
			cnode.hucode = hutype.NONE
			cnode.huazhu = 0
			cnode.dajiao = 0
			cnode.tuisui = 0

			self:insert_settle(settle, cnode.idx, cnode)
			self._players[ganginfo.idx]:record_settle(cnode)

			local settles = {}
			table.insert(settles, settle)

			ganginfo.settles = settles
			self:record("gang", ganginfo)
			self:push_client("gang", ganginfo)
		else
			assert(false)
		end
	elseif self._state == state.OCALL then
		self._state = state.GANG
		if ganginfo.code == opcode.zhigang then
			assert(self._curidx ~= ganginfo.idx)
			self._curidx = ganginfo.idx
			local res = self._players[ganginfo.idx]:gang(ganginfo, self._players[self._lastidx], self._lastcard)
			ganginfo.hor = res.hor

			local settle = {}
			local base = gangmultiple(opcode.zhigang)
			local win = {ganginfo.idx}
			local lose = {self._lastidx}
			
			local wnode = {}
			wnode.idx  = ganginfo.idx
			wnode.chip = base
			wnode.left = self._players[wnode.idx]:settle(wnode.chip)

			wnode.win  = win
			wnode.lose = lose
			wnode.gang = ganginfo.code
			wnode.hucode = hutype.NONE
			wnode.huazhu = 0
			wnode.dajiao = 0
			wnode.tuisui = 0

			self:insert_settle(settle, wnode.idx, wnode)
			self._players[ganginfo.idx]:record_settle(wnode)

			local lnode = {}
			lnode.idx  = self._lastidx
			lnode.chip = -base
			lnode.left = self._players[self._lastidx]:settle(lnode.chip)

			lnode.win  = win
			lnode.lose = lose
			lnode.gang = ganginfo.code
			lnode.hucode = hutype.NONE
			lnode.huazhu = 0
			lnode.dajiao = 0
			lnode.tuisui = 0
			
			self:insert_settle(settle, lnode.idx, lnode)
			self._players[self._lastidx]:record_settle(lnode)
			
			local settles = {}
			table.insert(settles, settle)
			ganginfo.settles = settles
			self:record("gang", ganginfo)
			self:push_client("gang", ganginfo)
		else
			assert(false)
		end
	else
		assert(false)
	end
end

function cls:check_firsthu(idx, ... )
	-- body
	assert(idx and idx > 0 and idx <= self._max)
	local count = 0
	for i=1,self._max do
		if self._players[i]:hashu() then
			count = count + 1
		end
	end
	if count == 1 then
		self._lastfirsthu = idx
	end
end

function cls:hu(hus, ... )
	-- body
	assert(hus)
	if self._state == state.MCALL then
		assert(#hus == 1)
		local huinfo = hus[1]
		self._state = state.HU
		self._players[self._curidx]:hu(huinfo, self._players[self._curidx], self._curcard)
		self:check_firsthu(self._curidx)
		
		local settle = {}
		local win = {}
		local lose = {}
		if huinfo.jiao == jiaotype.DIANGANGHUA then
			local base = self._humultiple(huinfo.code, huinfo.jiao, huinfo.gang)
			if self._dianganghua == 0 then
				table.insert(win, huinfo.idx)
				table.insert(lose, huinfo.dian)
				local wnode = {}
				wnode.idx  = huinfo.idx
				wnode.chip = base
				wnode.left = self._players[self._curidx]:settle(wnode.chip)

				wnode.win  = win
				wnode.lose = lose
				wnode.gang = opcode.none
				wnode.hucode = huinfo.code
				wnode.hujiao = huinfo.jiao
				wnode.hugang = huinfo.gang
				wnode.huazhu = 0
				wnode.dajiao = 0
				wnode.tuisui = 0
				self:insert_settle(settle, wnode.idx, wnode)
				self._players[self._curidx]:record_settle(wnode)

				local lnode = {}
				lnode.idx  = self._lastidx
				lnode.chip = -base
				lnode.left = settle._players[self._lastidx]:settle(wnode.chip)

				lnode.win  = win
				lnode.lose = lose
				lnode.gang = opcode.none
				lnode.hucode = huinfo.code
				lnode.hujiao = huinfo.jiao
				lnode.hugang = huinfo.gang
				lnode.huazhu = 0
				lnode.dajiao = 0
				lnode.tuisui = 0
				self:insert_settle(settle, lnode.idx, lnode)
				self._players[self._lastidx]:record_settle(lnode)
			else
				local total = 0
				table.insert(win, huinfo.idx)
				for i=1,self._max do
					if i == self._curidx then
					elseif self._players[i]:hashu() then
					else
						total = total + base
						table.insert(lose, i)
						local node = {}
						node.idx  = i
						node.chip = -base
						node.left = self._players[i]:settle(node.chip)

						node.win  = win
						node.lose = lose
						node.gang = opcode.none
						node.hucode = huinfo.code
						node.hujiao = huinfo.jiao
						node.hugang = huinfo.gang
						node.huazhu = 0
						node.dajiao = 0
						node.tuisui = 0
						self:insert_settle(settle, node.idx, node)
						self._players[i]:record_settle(node)
					end
				end
				local wnode = {}
				wnode.idx  = self._curidx
				wnode.chip = total
				wnode.left = self._players[self._curidx]:settle(wnode.chip)

				wnode.win  = win
				wnode.lose = lose
				wnode.gang = opcode.none
				wnode.hucode = huinfo.code
				wnode.hujiao = huinfo.jiao
				wnode.hugang = huinfo.gang
				wnode.huazhu = 0
				wnode.dajiao = 0
				wnode.tuisui = 0
				self:insert_settle(settle, wnode.idx, wnode)
				self._players[self._curidx]:record_settle(wnode)
			end
		elseif huinfo.jiao == jiaotype.ZIMO or
			huinfo.jiao == jiaotype.ZIGANGHUA then
			
			local base = self._humultiple(huinfo.code, huinfo.jiao, huinfo.gang)
			local total = 0
			local lose = {}
			local win = {huinfo.idx}
			for i=1,self._max do
				if i == self._curidx then
				elseif self._players[i]:hashu() then
				else
					total = total + base
					table.insert(lose, i)
					local node = {}
					node.idx  = i
					node.chip = -base
					node.left = self._players[i]:settle(node.chip)

					node.win  = win
					node.lose = lose
					node.gang = opcode.none
					node.hucode = huinfo.code
					node.hujiao = huinfo.jiao
					node.hugang = huinfo.gang
					node.huazhu = 0
					node.dajiao = 0
					node.tuisui = 0

					self:insert_settle(settle, node.idx, node)
					self._players[i]:record_settle(node)
				end
			end
			local wnode = {}
			wnode.idx  = self._curidx
			wnode.chip = total
			wnode.left = self._players[self._curidx]:settle(wnode.chip)

			wnode.win  = win
			wnode.lose = lose
			wnode.gang = opcode.none
			wnode.hucode = huinfo.code
			wnode.hujiao = huinfo.jiao
			wnode.hugang = huinfo.gang
			wnode.huazhu = 0
			wnode.dajiao = 0
			wnode.tuisui = 0

			self:insert_settle(settle, wnode.idx, wnode)
			self._players[self._curidx]:record_settle(wnode)
		else
			assert(false)
		end

		local settles = {}
		table.insert(settles, settle)

		local args = {}
		args.hus = hus
		args.settles = settles

		self:record("hu", args)
		self:push_client("hu", args)
	elseif self._state == state.OCALL then
		self._state = state.HU

		local settles = {}
		local count = 0
		local idx = self._curidx
		for i=1,self._max do
			local j = idx + i
			if j > self._max then
				j = j - self._max
			end
			for k,v in pairs(hus) do
				if v.idx == j then
					count = count + 1
					self._curidx = j

					local huinfo = self._players[v.idx]:hu(v, self._players[self._lastidx], self._lastcard)
					if v.jiao == jiaotype.QIANGGANGHU then
						-- tuisui
						local settle = {}
						self._players[huinfo.dian]:tuisui_with_qianggang(settle)
						table.insert(settles, settle)
					end
					local win = {huinfo.idx}
					local lose = {huinfo.dian}
					local settle = {}

					table.insert(win, v.idx)
					local base = self._humultiple(huinfo.code, huinfo.jiao, huinfo.gang)

					local wnode = {}
					wnode.idx  = huinfo.idx
					wnode.chip = base
					wnode.left = self._players[wnode.idx]:settle(wnode.chip)

					wnode.win  = win
					wnode.lose = lose
					wnode.gang = opcode.none
					wnode.hucode = huinfo.code
					wnode.hujiao = huinfo.jiao
					wnode.hugang = huinfo.gang
					wnode.huazhu = 0
					wnode.dajiao = 0
					wnode.tuisui = 0
					self:insert_settle(settle, wnode.idx, wnode)
					self._players[wnode.idx]:record_settle(wnode)
					
					local lnode = {}
					lnode.idx  = huinfo.dian
					lnode.chip = -base
					lnode.left = self._players[lnode.idx]:settle(lnode.chip)

					lnode.win  = win
					lnode.lose = lose
					lnode.gang = opcode.none
					lnode.hucode = huinfo.code
					lnode.hujiao = huinfo.jiao
					lnode.hugang = huinfo.gang
					lnode.huazhu = 0
					lnode.dajiao = 0
					lnode.tuisui = 0

					self:insert_settle(settle, lnode.idx, lnode)
					self._players[lnode.idx]:record_settle(lnode)

					table.insert(settles, settle)			
					break
				end
			end
			if count == #hus then
				break
			end
		end
		
		if #hus > 1 then
			self._lastwin = self._lastidx
		else
			self._lastwin = self._curidx
		end

		local args = {}
		args.hus = hus
		args.settles = settles
		self:push_client("hu", args)
	else
		assert(false)
	end
end

function cls:_next( ... )
	-- body
	if self:check_over() then
		self:take_over()
	else
		self._curidx = self:next_idx()
		self._curcard = self:take_card()
		self._players[self._curidx]:take_turn_card(self._curcard)
		if self._curcard then
			if self:take_mcall() then
			else
				self:take_turn()
			end
		else
			self:take_over()
		end	
	end
end

function cls:guo( ... )
	-- body
	if self._state == state.MCALL then
		self:take_turn()
	elseif self._state == state.LEAD then
		self:_next()
	elseif self._state == state.OCALL then
		log.info("player guo")
		self:_next()
	else
		assert(false)
	end
end

function cls:_calc_call( ... )
	-- body
	if self._callsz > 0 then
		if self._callhu > 0 then
			if self._callhux <= 0 then
				if #self._huinfos > 0 then
					if self._callpeng > 0 then
						for i=1,self._max do
							local call = self._call[i]
							if call.peng then
								call.peng = false
								self._callpengx = self._callpengx - 1
								self._players[i]:cancel_timeout()
							end
						end
						assert(self._callpengx <= 0)
					end
					if self._callgang > 0 then
						for i=1,self._max do
							local call = self._call[i]
							if call.gang then
								call.gang = false
								self._callgangx = self._callgangx - 1
								self._players[i]:cancel_timeout()
							end
						end
						assert(self._callgangx <= 0)
					end
					self:hu(self._huinfos)
				end
			end
		end
	else
		if self._callhu > 0 then -- first
			if self._callhux <= 0 then
				if #self._huinfos > 0 then
					self:hu(self._huinfos)
				else
					if self._callgang > 0 then
						assert(self._callgangx <= 0)
						if self._callgangx <= 0 then
							if self._ganginfo then
								self:gang(self._ganginfo)
							else
								self:guo()
							end
						else
						end
					elseif self._callpeng > 0 then
						assert(self._callpengx <= 0)
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
end

function cls:call(opinfo, ... )
	-- body
	if self._state == state.OCALL or self._state == state.MCALL then
		local call = assert(self._call[opinfo.idx])
		self._callsz = self._callsz - 1
		self._players[opinfo.idx]:cancel_timeout()
		if call.hu then
			call.hu = false
			if opinfo.hu.code ~= hutype.NONE then -- selected
				local hu = {}
				hu.idx  = opinfo.hu.idx
				hu.card = opinfo.hu.card
				hu.code = opinfo.hu.code
				hu.gang = opinfo.hu.gang
				hu.jiao = opinfo.hu.jiao
				hu.dian = opinfo.hu.dian
				table.insert(self._huinfos, hu)
			end
			self._callhux = self._callhux - 1
		end
		if call.gang then
			call.gang = false
			if opinfo.gang ~= opcode.none then
				local gang = {}
				gang.idx  = opinfo.idx
				gang.card = opinfo.card
				gang.code = opinfo.gang
				gang.dian = opinfo.dian
				self._ganginfo = gang
			end
			self._callgangx = self._callgangx - 1
		end
		if call.peng then
			call.peng = false
			if opinfo.peng ~= opcode.none then
				local peng = {}
				peng.idx  = opinfo.idx
				peng.card = opinfo.card
				peng.code = opinfo.peng
				peng.dian = opinfo.dian
				self._penginfo = peng
			end
			self._callpengx = self._callpengx - 1
		end
		self:_calc_call()
	end
end

function cls:timeout_call(idx, ... )
	-- body
	if self._state == state.OCALL or self._state == state.MCALL then
		local call = assert(self._call[idx])
		self._callsz = self._callsz - 1
		if call.hu then -- only 1
			call.hu = false
			if self._players[idx]._hu.jiao == jiaotype.ZIMO then
				local hu = {}
				hu.idx = self._players[idx]._hu.idx
				hu.card = self._players[idx]._hu.card:get_value()
				hu.code = self._players[idx]._hu.code
				hu.jiao = self._players[idx]._hu.jiao
				hu.dian = self._players[idx]._hu.dian
				table.insert(self._huinfos, hu)
			end
			self._callhux = self._callhux - 1
		end
		if call.gang then
			call.gang = false
			self._callgangx = self._callgangx - 1
		end
		if call.peng then
			call.peng = false
			self._callpengx = self._callpengx - 1
		end
		self:_calc_call()
		log.info("player %d timeout call", idx)
	end
end

function cls:take_over( ... )
	-- body
	self._state = state.OVER
	self:clear_state(player.state.OVER)

	self:record("over")
	self:push_client("over")
end

function cls:take_settle( ... )
	-- body
	self._state = state.SETTLE
	self:clear_state(player.state.SETTLE)

	local settles = {}
	local wuhu = 0
	for i=1,self._max do
		if not self._players[i]:hashu() then
			wuhu = wuhu + 1
		end
	end
	if wuhu > 1 then
		-- check hua zhu
		local huazhus = {}
		local wudajiaos = {}
		local dajiaos = {}
		for i=1,self._max do
			if self._players[i]:hashu() then
			else
				if self._players[i]:check_que() then
					local res = self._players[i]:check_jiao()
					res.idx = i
					if res.code ~= hutype.NONE then
						table.insert(dajiaos, res)
					else
						table.insert(wudajiaos, res)
					end
				else
					table.insert(huazhus, { idx = i })
				end
			end
		end
		-- tuisui
		if #huazhus > 0 then
			for k,v in pairs(huazhus) do
				local settle = {}
				self._players[v.idx]:tuisui(settle)
				table.insert(settles, settle)
			end
		end

		if #dajiaos == wuhu then
		elseif #dajiaos > 0 then

			for k,v in pairs(dajiaos) do
				local settle = {}

				local base = self._humultiple(v.code, jiaotype.PINGFANG, v.gang)
				local total = 0
				local lose = {}
				local win = {}

				table.insert(win, v.idx)
				for k,h in pairs(wudajiaos) do
					total = total + base
					table.insert(lose, h.idx)

					local litem = {}
					litem.idx  = h.idx
					litem.chip = -base
					litem.left = self._players[litem.idx]:settle(litem.chip)

					litem.win  = win
					litem.lose = lose
					litem.gang = opcode.none
					litem.hucode = v.code
					litem.hujiao = jiaotype.PINGFANG
					litem.hugang = v.gang
					litem.huazhu = 0
					litem.dajiao = 1
					litem.tuisui = 0

					self:insert_settle(settle, litem.idx, litem)
					self._players[litem.idx]:record_settle(litem)
				end
				for k,h in pairs(huazhus) do						
					total = total + base
					table.insert(lose, h.idx)

					local litem = {}
					litem.idx = h.idx
					litem.chip = -base
					litem.left = self._players[litem.idx]:settle(litem.chip)

					litem.win = win
					litem.lose = lose
					litem.gang = opcode.none
					litem.hucode = v.code
					litem.hujiao = hutype.PINGFANG
					litem.hugang = v.gang
					litem.huazhu = 1
					litem.dajiao = 0
					litem.tuisui = 0

					self:insert_settle(settle, litem.idx, litem)
					self._players[h.idx]:record_settle(litem)
				end	

				local witem = {}
				witem.idx = v.idx
				witem.chip = total
				witem.left = self._players[v.idx]:settle(witem.chip)

				witem.win  = win
				witem.lose = lose
				witem.gang = opcode.none
				witem.hucode = v.code
				witem.hujiao = jiaotype.PINGFANG
				witem.hugang = v.gang

				witem.huazhu = 0
				witem.dajiao = 1
				witem.tuisui = 0
				self:insert_settle(settle, witem.idx, witem)
				self._players[v.idx]:record_settle(witem)
			end
		end		
	end
	local args = {}
	args.settles = settles

	self:record("settle", args)
	self:push_client("settle", args)
end

function cls:take_final_settle( ... )
	-- body
	self._state = state.FINAL_SETTLE
	self:clear_state(player.state.FINAL_SETTLE)

	local over = false
	if self._ju == self._maxju then
		-- over
		over = true
		skynet.send(".ROOM_MGR", "lua", "enqueue_room", self._id)
		for i=1,self._max do
			local addr = self._players[i]:get_agent()
			skynet.send(addr, "lua", "room_over")
		end
	end

	local args = {}
	args.p1 = self._players[1]._chipli
	args.p2 = self._players[2]._chipli
	args.p3 = self._players[3]._chipli
	args.p4 = self._players[4]._chipli
	args.settles = settles
	args.over = over

	self:record("final_settle", args)
	local recordid = skynet.call(".RECORD_MGR", "lua", "register", cjson.encode(self._record))
	self._record = {}
	local names = {}
	for i=1,self._max do
		table.insert(names, self._players[i]:get_name())
	end
	for i=1,self._max do
		local addr = self._players[i]:get_agent()
		skynet.send(addr, "lua", "record", recordid, names)
	end

	self:push_client("final_settle", args)
end

function cls:restart(idx, ... )
	-- body
	if self._state == state.FINAL_SETTLE then
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

	self._lastidx  = 0    -- last time lead from who
	self._lastcard = nil    -- last time lead card

	self._firsttake = 0
	self._firstidx  = 0    -- zhuangjia
	self._curtake   = 0
	self._curidx    = 0      -- player
	self._curcard = nil
	
	self._takeround = 1
	self._takeidx = 0       -- count

	for i=1,self._max do
		self._players[i]:take_restart()
	end

	self:push_client("take_restart")
end

function cls:chat(args, ... )
	-- body
	if self._state >= state.READY and self._state < state.OVER then
		self:push_client("rchat", args)
	end
end

function cls:take_roomover( ... )
	-- body
end

function cls:insert_settle(settle, idx, item, ... )
	-- body
	assert(settle and idx and item)
	assert(idx > 0 and idx <= self._max)
	if idx == 1 then
		assert(settle.p1 == nil)
		settle.p1 = item
	elseif idx == 2 then
		assert(settle.p2 == nil)
		settle.p2 = item
	elseif idx == 3 then
		assert(settle.p3 == nil)
		settle.p3 = item
	elseif idx == 4 then
		assert(settle.p4 == nil)
		settle.p4 = item
	else
		assert(false)
	end
end

return cls