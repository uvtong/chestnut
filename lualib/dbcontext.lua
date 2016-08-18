local cls = class("dbcontext")

function cls:ctor(env, rdb, wdb, ... )
	-- body
	self._env = env
	self._rdb = rdb
	self._wdb = wdb
	self._data = {}
	return self
end

function cls:load()
end

return cls