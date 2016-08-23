local card = require "card"
local cls = class("player")

function cls:ctor(env, ... )
	-- body
	self._env = env
	self._uid = false
	self._addr = false
	self._last = false
	self._next = false
	self._ready = false
	self._rob = {}
	self._cards = {}
	return self
end

function cls:set_uid(uid, ... )
	-- body
	self._uid = uid
end

function cls:get_uid( ... )
	-- body
	return self._uid
end

function cls:set_addr(addr, ... )
	-- body
	self._addr = addr
end

function cls:get_addr( ... )
	-- body
	return self._addr
end

function cls:set_last(player, ... )
	-- body
	self._last = player
end

function cls:get_last( ... )
	-- body
	return self._last
end

function cls:set_next(player, ... )
	-- body
	self._next = player
end

function cls:get_next( ... )
	-- body
	return self._next
end

function cls:set_ready(flag, ... )
	-- body
	self._ready = flag
end

function cls:get_ready( ... )
	-- body
	return self._ready
end

function cls:set_rob(flag, ... )
	-- body
	local sz = #self._rob
	if sz == 2 then
		return false
	else
		sz = sz	+ 1
		self._rob[sz] = flag
	end
end

function cls:get_rob( ... )
	-- body
	return self._rob
end

function cls:deal(v, ... )
	-- body
	local c = card.new(v)
	table.insert(self._cards, c)
end

function cls:lead(cards, ... )
	-- body
end

function cls:is_over( ... )
	-- body
end

return cls