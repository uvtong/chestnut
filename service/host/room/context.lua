local skynet = require "skynet"
local card = require "card"
local env = require "env"
local cls = class("context", env)

function cls:ctor( ... )
	-- body
	self._players = {}
	self._uid_map = {}
	self._front_cards = {}
	self._back_cards  = {}
	self:init_cards()
	self._first_player = false
	return self
end

function cls:add(player, ... )
	-- body
	table.insert(self._players, player)
	local uid = player:get_uid()
	self._uid_map[uid] = player
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
end

function cls:get_players()
	return self._players
end

function cls:get_player(uid, ... )
	-- body
	return self._uid_map[uid]
end

function cls:init_cards( ... )
	-- body
	table.insert(self._front_cards, (0 << 4 & 1))
	table.insert(self._front_cards, (0 << 4 & 2))
	table.insert(self._front_cards, (0 << 4 & 3))
	table.insert(self._front_cards, (0 << 4 & 4))
	table.insert(self._front_cards, (0 << 4 & 5))
	table.insert(self._front_cards, (0 << 4 & 6))
	table.insert(self._front_cards, (0 << 4 & 7))
	table.insert(self._front_cards, (0 << 4 & 8))
	table.insert(self._front_cards, (0 << 4 & 9))
	table.insert(self._front_cards, (0 << 4 & 10))
	table.insert(self._front_cards, (0 << 4 & 11))
	table.insert(self._front_cards, (0 << 4 & 12))
	table.insert(self._front_cards, (0 << 4 & 13))

	table.insert(self._front_cards, (1 << 4 & 1))
	table.insert(self._front_cards, (1 << 4 & 2))
	table.insert(self._front_cards, (1 << 4 & 3))
	table.insert(self._front_cards, (1 << 4 & 4))
	table.insert(self._front_cards, (1 << 4 & 5))
	table.insert(self._front_cards, (1 << 4 & 6))
	table.insert(self._front_cards, (1 << 4 & 7))
	table.insert(self._front_cards, (1 << 4 & 8))
	table.insert(self._front_cards, (1 << 4 & 9))
	table.insert(self._front_cards, (1 << 4 & 10))
	table.insert(self._front_cards, (1 << 4 & 11))
	table.insert(self._front_cards, (1 << 4 & 12))
	table.insert(self._front_cards, (1 << 4 & 13))

	table.insert(self._front_cards, (2 << 4 & 1))
	table.insert(self._front_cards, (2 << 4 & 2))
	table.insert(self._front_cards, (2 << 4 & 3))
	table.insert(self._front_cards, (2 << 4 & 4))
	table.insert(self._front_cards, (2 << 4 & 5))
	table.insert(self._front_cards, (2 << 4 & 6))
	table.insert(self._front_cards, (2 << 4 & 7))
	table.insert(self._front_cards, (2 << 4 & 8))
	table.insert(self._front_cards, (2 << 4 & 9))
	table.insert(self._front_cards, (2 << 4 & 10))
	table.insert(self._front_cards, (2 << 4 & 11))
	table.insert(self._front_cards, (2 << 4 & 12))
	table.insert(self._front_cards, (2 << 4 & 13))

	table.insert(self._front_cards, (3 << 4 & 1))
	table.insert(self._front_cards, (3 << 4 & 2))
	table.insert(self._front_cards, (3 << 4 & 3))
	table.insert(self._front_cards, (3 << 4 & 4))
	table.insert(self._front_cards, (3 << 4 & 5))
	table.insert(self._front_cards, (3 << 4 & 6))
	table.insert(self._front_cards, (3 << 4 & 7))
	table.insert(self._front_cards, (3 << 4 & 8))
	table.insert(self._front_cards, (3 << 4 & 9))
	table.insert(self._front_cards, (3 << 4 & 10))
	table.insert(self._front_cards, (3 << 4 & 11))
	table.insert(self._front_cards, (3 << 4 & 12))
	table.insert(self._front_cards, (3 << 4 & 13))

	table.insert(self._front_cards, (4 << 4 & 0))
	table.insert(self._front_cards, (5 << 4 & 0))	
end

function cls:get_cards( ... )
	-- body
	return self._front_cards
end

function cls:shuffle( ... )
	-- body
	return self._front_cards
end

function cls:deal_cards( ... )
	-- body
end

function cls:deal(player, ... )
	-- body
	local sz = #self._front_cards
	for i=1,sz,3 do
		local v = self._front_cards[i]

	end
end

function cls:set_first_player(player, ... )
	-- body
	self._first_player = player
end

function cls:get_first_player( ... )
	-- body
	return self._first_player
end

return cls