local skynet = require "skynet"
local cls = class("mailbox")

function cls:ctor(env, ... )
	-- body
	self._env = env
	self._uid = false
	self._mailidx = 0
	return self
end

function cls:get_uid( ... )
	-- body
end

function cls:receive(mail, ... )
	-- body

end

function cls:send( ... )
	-- body
end

return cls