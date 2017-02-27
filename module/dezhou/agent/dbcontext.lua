local skynet = require "skynet"
local query = require "query"
local field = require "db.field"
local checkindailymgr = require "checkindailymgr"

local cls = class("dbcontext")

function cls:ctor(env, ... )
	-- body
	self._env = env
	self._user = nil
	return self
end

function cls:register_user(u, ... )
	-- body
	self._user = u
end

return cls