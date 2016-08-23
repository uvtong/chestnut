local cls = class("mail")

function cls:ctor(env, ... )
	-- body
	self._env = env
	self._idx = false
	return self
end

function cls:set_idx(idx ... )
	-- body
	self._idx = idx
end

function cls:get_idx( ... )
	-- body
	return self._idx
end

function function_name( ... )
	-- body
end

function cls:set_head(head ... )
	-- body
end

return cls