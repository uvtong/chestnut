local notification = require "notification"
local assert = assert

local cls = class("notification_center")

function cls:ctor(env, ... )
	-- body
	assert(env)
	self._env = env
	self._observers = {}
	return self
end

function cls:add_observer(func, name, object, ... )
	-- body
	assert(func and name)
	local n = notification.new(self._env)
	n:set_func(func)
	n:set_name(name)
	n:set_object(object)
	self._observers[name] = n
end

function cls:remove_observer(name, object, ... )
	-- body
	self._observers[name] = nil
end

function cls:post_notification_name(name, object, ... )
	-- body
	local n = self._observers[name]
	if n then
		local func = n:get_func()
		if typeof(func) == "table" then
			local f = func.f
			local u = func.u
			f(u, n)
		elseif typeof(func) == "function" then
			func(n)
		end
	end
end

return cls
