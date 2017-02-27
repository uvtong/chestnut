local skynet = require "skynet"
local dbcontext = require "dbcontext"

local cls = class("mail_udbcontext")

function cls:ctor(env, rdb, wdb, ... )
	-- body
	cls.super.ctor(self, env, rdb, wdb)
	return self
end

return cls
