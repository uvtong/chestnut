local center = require "notification_center"

local cls = class("env")

function cls:ctor( ... )
	-- body
	self._center = center.new(self)
	return self
end

function cls:post_notification_name(name, object, ... )
	self._center:post_notification_name(name, object, ...)
end

return cls