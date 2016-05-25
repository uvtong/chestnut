local cls = class("helper")

function cls:test(env, ... )
	-- body
	self._env = env
	self._user = env:get_user()
end

return cls