local cls = class("dbcontext")

function cls:ctor(env, ... )
	-- body
	self._env = env
	self._data = {}
	return self
end

function cls:load()
end

return cls