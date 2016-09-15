local skynet = require "skynet"
local center = require "notification_center"
local gamecontroller = require "gamecontroller"
local card = require "card"
local env = require "env"
local cls = class("context", env)

function cls:ctor( ... )
	-- body
	cls.super.ctor(self)

	self._players = {}
	self._uid_player = {}
	self._fd_player = {}

	self._front_cards = {}
	self._back_cards  = {}
	self:init_cards()
	self._fapai_idx = 0

	self._controllers = {}
	self._controllers.game = gamecontroller.new(self, "game")
	return self
end

function cls:add(player, ... )
	-- body
	local uid = player:get_uid()
	self._uid_player[uid] = player
	local fd = player:get_fd()
	self._fd_player[fd] = player

	table.insert(self._players, player)
	local idx = #self._players
	player:set_idx(idx)
	if idx == 3 then
		for i=1,3 do
			local player = self._players[i]
			local idx = i - 1 and i - 1 or 3
			local last = self._players[idx]
			player:set_last(last)
			local idx = i + 1 % 3
			local next = self._players[idx]
			player:set_next(next)

			self:send_package()
		end
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
end

function cls:get_players()
	return self._players
end

function cls:get_player_by_uid(uid, ... )
	-- body
	return self._uid_map[uid]
end

function cls:get_player_by_fd(fd, ... )
	-- body
	return self._fd_player[fd]
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
	return self._front_cards
end

function cls:next_card( ... )
	-- body
	self._fapai_idx = self._fapai_idx + 1
	local card = self._front_cards[self._fapai_idx]
	return card
end

function cls:rest_of_deal( ... )
	-- body
	assert(self._fapai_idx >= 0 and self._fapai_idx <= 54)
	return 54 - self._fapai_idx
end

function cls:get_controller(name, ... )
	-- body
	return self._controllers[name]
end

function cls:clear( ... )
	-- body
	self._players = {}
	self._uid_player = {}
	self._fd_player = {}
end

return cls