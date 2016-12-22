local skynet = require "skynet"
local cls = class("dbcontext")

function cls:ctor(env, ... )
	-- body
	self._env = env
	self._data = {}
	return self
end

function cls:login( ... )
	-- body
end

function cls:afx( ... )
	-- body
end

function cls:update_db( ... )
	-- body
end

function cls:load()
end



return cls