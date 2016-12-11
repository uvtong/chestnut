local skynet = require "skynet"
local gamecontroller = require "gamecontroller"
local card = require "card"
local player = require "player"
local log = require "log"
local list = require "list"

local state = {}
state.NONE       = 0
state.START      = 1
state.ENTER_ROOM = 2

local cls = class("rcontext")

function cls:ctor( ... )
	-- body

	self._list = list.new()
	for i=1,3 do
		local tmp = player.new(self)
		list.insert_tail(self._list, tmp)
	end

	self._players = {}
	self._uid_player = {}
	self._sid_player = {}

	self._front_cards = {}
	self._back_cards  = {}
	self:init_cards()
	self._fapai_idx = 0

	self._controllers = {}
	self._controllers.game = gamecontroller.new(self, "game")
	return self
end

function cls:create_player(uid, sid, agent, ... )
	-- body
	assert(#self._players < 3)
	if self._uid_player[uid] then
		log.info("this player has enter")
		return nil
	else
		local tmp = list.pop(self._list)
		tmp:set_uid(uid)
		tmp:set_sid(sid)
		tmp:set_agent(agent)
		return tmp
	end
end

function cls:release_player(p, ... )
	-- body
	list.insert_tail(self._list, p)
end

function cls:add(player, ... )
	-- body
	log.info("rcontext add")
	local uid = player:get_uid()
	local sid = player:get_sid()
	self._uid_player[uid] = player
	self._sid_player[sid] = player

	local sz = #self._players
	table.insert(self._players, player)
	if sz == 0 then
	elseif sz == 1 then
		local last = self._players[1]
		last:set_next(player)
		player:set_last(last)
	elseif sz == 2 then
		local last = self._players[2]
		local next = self._players[1]
		
		last:set_next(player)
		player:set_last(last)

		next:set_last(player)
		player:set_next(next)
	else
		assert(false)
	end
end

function cls:remove(player, ... )
	-- body
	for i=1,3 do
		if self._players[i] == player then
			self._players[i] = nil
			break
		end
	end
	local uid = player:get_uid()
	self._uid_map[uid] = nil
	local agent = player:get_agent()
	self._agent_player[agent] = nil
	local last = player:get_last()
	if last then
		last:set_next(nil)
	end
	local next = player:get_next()
	if next then
		next:set_last(nil)
	end
end

function cls:get_players()
	return self._players
end

function cls:get_players_count( ... )
	-- body
	return #self._players
end

function cls:get_player_by_uid(uid, ... )
	-- body
	assert(false)
	return self._uid_player[uid]
end

function cls:get_player_by_sid(sid, ... )
	-- body
	assert(sid)
	return self._sid_player[sid]
end

-- only for player
function cls:clear( ... )
	-- body
	for i=1,3 do
		local tmp = self._players[i]
		self:release_player(tmp)
	end
	self._players = {}
	self._uid_player = {}
	self._sid_player = {}
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

function cls:get_controller(name, ... )
	-- body
	return self._controllers[name]
end

return cls