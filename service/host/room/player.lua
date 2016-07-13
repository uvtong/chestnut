local cls = class("player")

function cls:ctor( ... )
	-- body
	self._cards = {}
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

return cls