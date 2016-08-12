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

function cls:add_observer(handler, name, object, ... )
	-- body
	assert(func and name)
	local n = notification.new(self._env)
	n:set_func(handler)
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
		local object = n:get_object()
		if object then
			n:set_object(object)
		end
		
		local handler = n:get_func()
		if handler then
			handler(n)
		end
	end
end

return cls
