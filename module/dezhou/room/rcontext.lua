local skynet = require "skynet"
local gamecontroller = require "gamecontroller"
local card = require "card"
local player = require "player"
local log = require "log"
local list = require "list"
local util = require "util"

local state = {}
state.NONE       = 0
state.START      = 1
state.ENTER_ROOM = 2
state.PERFLOP    = 3
state.FLOP       = 4
state.TURN       = 5
state.RIVER      = 6
state.COMPARE    = 7

local cls = class("rcontext")

function cls:ctor( ... )
	-- body
	self._players = {}
	for i=1,6 do
		local tmp = player.new(self)
		tmp._idx = i
		table.insert(self._players, tmp)
	end
	self._online = 0
	
	self._front_cards = {}
	self._fapai_idx = 0
	self:init_cards()
	
	self._state = state.NONE
	self._cards = {}
	self._lastwin = nil -- last 
	self._bblind_note = nil
	self._sblind_note = nil

	return self
end

function cls:get_online( ... )
	-- body
	return self._online
end

function cls:incre_online( ... )
	-- body
	self._online = self._online + 1
	if self._online > 6 then
		self._online = 6
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
	if self._online >= 6 then
		self._online = 6
		return
	end
	assert(self._online >= 0)
	for i=1,6 do
		if self._players[i]._noone then
			return self._players[i]
		end
	end
end

function cls:get_players()
	return self._players
end

function cls:get_player_by_uid(uid, ... )
	-- body
	assert(uid)
	for i=1,6 do
		local p = assert(self._players[i])
		if p._uid == uid then
			return p
		end
	end
end

function cls:get_player_by_sid(sid, ... )
	-- body
	assert(sid)
	for i=1,6 do
		local p = assert(self._players[i])
		if p._sid == sid then
			return p
		end
	end
end

function cls:init_cards( ... )
	-- body
	table.insert(self._front_cards, card.new((0 << 4 | 1)))
	table.insert(self._front_cards, card.new((0 << 4 | 2)))
	table.insert(self._front_cards, card.new((0 << 4 | 3)))
	table.insert(self._front_cards, card.new((0 << 4 | 4)))
	table.insert(self._front_cards, card.new((0 << 4 | 5)))
	table.insert(self._front_cards, card.new((0 << 4 | 6)))
	table.insert(self._front_cards, card.new((0 << 4 | 7)))
	table.insert(self._front_cards, card.new((0 << 4 | 8)))
	table.insert(self._front_cards, card.new((0 << 4 | 9)))
	table.insert(self._front_cards, card.new((0 << 4 | 10)))
	table.insert(self._front_cards, card.new((0 << 4 | 11)))
	table.insert(self._front_cards, card.new((0 << 4 | 12)))
	table.insert(self._front_cards, card.new((0 << 4 | 13)))

	table.insert(self._front_cards, card.new((1 << 4 | 1)))
	table.insert(self._front_cards, card.new((1 << 4 | 2)))
	table.insert(self._front_cards, card.new((1 << 4 | 3)))
	table.insert(self._front_cards, card.new((1 << 4 | 4)))
	table.insert(self._front_cards, card.new((1 << 4 | 5)))
	table.insert(self._front_cards, card.new((1 << 4 | 6)))
	table.insert(self._front_cards, card.new((1 << 4 | 7)))
	table.insert(self._front_cards, card.new((1 << 4 | 8)))
	table.insert(self._front_cards, card.new((1 << 4 | 9)))
	table.insert(self._front_cards, card.new((1 << 4 | 10)))
	table.insert(self._front_cards, card.new((1 << 4 | 11)))
	table.insert(self._front_cards, card.new((1 << 4 | 12)))
	table.insert(self._front_cards, card.new((1 << 4 | 13)))

	table.insert(self._front_cards, card.new((2 << 4 | 1)))
	table.insert(self._front_cards, card.new((2 << 4 | 2)))
	table.insert(self._front_cards, card.new((2 << 4 | 3)))
	table.insert(self._front_cards, card.new((2 << 4 | 4)))
	table.insert(self._front_cards, card.new((2 << 4 | 5)))
	table.insert(self._front_cards, card.new((2 << 4 | 6)))
	table.insert(self._front_cards, card.new((2 << 4 | 7)))
	table.insert(self._front_cards, card.new((2 << 4 | 8)))
	table.insert(self._front_cards, card.new((2 << 4 | 9)))
	table.insert(self._front_cards, card.new((2 << 4 | 10)))
	table.insert(self._front_cards, card.new((2 << 4 | 11)))
	table.insert(self._front_cards, card.new((2 << 4 | 12)))
	table.insert(self._front_cards, card.new((2 << 4 | 13)))

	table.insert(self._front_cards, card.new((3 << 4 | 1)))
	table.insert(self._front_cards, card.new((3 << 4 | 2)))
	table.insert(self._front_cards, card.new((3 << 4 | 3)))
	table.insert(self._front_cards, card.new((3 << 4 | 4)))
	table.insert(self._front_cards, card.new((3 << 4 | 5)))
	table.insert(self._front_cards, card.new((3 << 4 | 6)))
	table.insert(self._front_cards, card.new((3 << 4 | 7)))
	table.insert(self._front_cards, card.new((3 << 4 | 8)))
	table.insert(self._front_cards, card.new((3 << 4 | 9)))
	table.insert(self._front_cards, card.new((3 << 4 | 10)))
	table.insert(self._front_cards, card.new((3 << 4 | 11)))
	table.insert(self._front_cards, card.new((3 << 4 | 12)))
	table.insert(self._front_cards, card.new((3 << 4 | 13)))

	table.insert(self._front_cards, card.new((4 << 4 | 0)))
	table.insert(self._front_cards, card.new((5 << 4 | 0)))	
end

function cls:shuffle( ... )
	-- body
	self._fapai_idx = 0
	return self._front_cards
end

function cls:next_card( ... )
	-- body
	self._fapai_idx = self._fapai_idx + 1
	assert(self._fapai_idx > 0 and self._fapai_idx <= 54)
	return self._front_cards[self._fapai_idx]
end

function cls:rest_of_deal( ... )
	-- body
	assert(#self._front_cards == 54)
	assert(self._fapai_idx >= 0 and self._fapai_idx <= 54)
	return (54 - self._fapai_idx)
end

function cls:get_pack_cards( ... )
	-- body
	local cards = {}
	for i,card in ipairs(self._front_cards) do
		table.insert(cards, card:get_value())
	end
	return cards
end

function cls:push_client(name, args, ... )
	-- body
	for i=1,6 do
		local p = self._players[i]
		if p._online and not p._noone then
			skynet.send(p._agent, "lua", name, args)
		end
	end
end

function cls:start( ... )
	-- body
	local cb = cc.handler(self, cls.check_start)
	util.set_timeout(400, cb)
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

function cls:next_player(start, ... )
	-- body
	if not start._noone and start._online then
		return start
	else
		local idx = assert(start._idx)
		for i=1,6 do
			local index = (idx + i) > 6 and (idx + i - 6) or idx + i
			local p = self._players[index]
			if not p._noone and p._online then
				return p
			end
		end
	end
end

function cls:join(uid, sid, agent, name,  ... )
	-- body
	local me = assert(self:find_noone())
	me:set_uid(uid)
	me:set_sid(sid)
	me:set_agent(agent)
	me:set_name(name)

	me:set_noone(false)

	return me
end

function cls:leave(uid, ... )
	-- body
	local p = assert(self:get_player_by_uid(uid))
	p:set_noone(true)
	p:set_online(false)
end

function cls:perflop( ... )
	-- body
	self._state = state.PERFLOP
	if self._lastwin == nil	then
		self._lastwin = assert(self._players[1])
	end
	local args = {}
	args.your_turn = self._lastwin:get_sid()
	args.countdown = 10
	for k,v in pairs(self._players) do
		v._online = true
		local cards = {}
		local card = self:next_card()
		table.insert(cards, card._value)
		args.cards = cards
		local addr = v:get_agent()
		skynet.send(addr, "lua", "ready", args)
	end
end

function cls:flop( ... )
	-- body
	assert(self._state == state.PERFLOP)
	self._state = state.FLOP

	local args = {}
	args.your_turn = self:next_player():get_sid()
	args.countdown = 10
	args.cards = {}

	for i=1,3 do
		self._cards[i] = self:next_card()
		table.insert(args.cards, self._cards[i]:get_value())
	end

	self:push_client("flop", args)
end

function cls:turn( ... )
	-- body
	assert(self._state == state.FLOP)
	self._state = state.TURN

	local args = {}
	args.your_turn = self:next_player(self._sblind_note):get_sid()
	args.countdown = 10
	args.cards = {}

	self._cards[4] = self:next_card()
	table.insert(args.cards, self._cards[4]:get_value())

	self:push_client("turn", args)

end

function cls:river( ... )
	-- body
	assert(self._state == state.TURN)
	self._state = state.TURN

	local args = {}
	
end

function cls:compare( ... )
	-- body
end


return cls