local skynet = require "skynet"
local cls = class("player")

function cls:ctor( ... )
	-- body
	self._uid = uid
	self._src = src
end

return cls