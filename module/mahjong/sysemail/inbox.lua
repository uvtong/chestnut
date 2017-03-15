local set = require "db.dbset"
local query = require "query"
local mail = require "mail"
local cls = class("inbox", set)

function cls:ctor(env, dbctx, ... )
	-- body
	cls.super.ctor(self, env, dbctx)
	self._tname = "tg_sysmail"
	return self
end

function cls:load_db_to_data( ... )
	-- body
	local sql = string.format("select * from %s", set._tname)
	local res = query.select(self._tname, sql)
	if #res > 0 then
		for k,v in pairs(res) do
			local m = mail.new(self._env, self._dbctx, self)
			for kk,vv in pairs(table_name) do
				m[kk].value = vv
			end
		end
	end
end

return cls