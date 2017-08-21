local cls = class("module")

function cls:ctor(env, name, ... )
	-- body
	assert(env and name)
	self._env = env
	self._name = name
	self._db = value

	env:register_module(name, self)
end

function cls:set_db(value, ... )
	-- body
	self._db = value
end

function cls:login( ... ) 
end

function cls:logout( ... )
	-- body
end

function cls:authed( ... )
	-- body
end

function cls:afx( ... )
	-- body
end

function cls:load_cache_to_data( ... )
	-- body
end