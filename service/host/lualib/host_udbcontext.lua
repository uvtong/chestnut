local u_wallet_set = require "models.u_wallet_set"
local dbcontext = require "dbcontext"
local cls = class("host_dbcontext", dbcontext)

function cls:ctor(env, rdb, wdb, ... )
	-- body
	cls.super.ctor(self, env, rdb, wdb)
	self._u_wallet_set = u_wallet_set.new(env, self, rdb, wdb)
	return self
end

function cls:load_db_to_data( ... )
	-- body
	self._u_wallet_set:load_db_to_data()
end

return cls