local cls = class("dbcontext")

function cls:ctor( ... )
	-- body
	self._data = {}
	return self
end

function cls:load()
end

return cls