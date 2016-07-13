local cls = class("context")

function cls:ctor( ... )
	-- body
	return self
end

function cls:set_host(h, ... )
	-- body
	self._host = h
end

return cls