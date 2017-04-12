local skynet = require "skynet"
local query = require "query"
local field = require "db.field"
local checkindailymgr = require "checkindailymgr"

local cls = class("dbcontext")

function cls:ctor(env, ... )
	-- body
	self._env = env
	self._data = {}
	self._user = nil
	self._online = false
	return self
end

function cls:register_set(set, ... )
	-- body
	table.insert(self._data, set)
end

function cls:register_user(u, ... )
	-- body
	self._user = u
end

function cls:get_checkindailymgr( ... )
	-- body
	return self._checkindailymgr
end

function cls:newborn( ... )
	-- body
end

function cls:login( ... )
	-- body
	self:load_db_to_data()
end

function cls:authed( ... )
	-- body
	self._online = true
	-- local cb = cc.handler(self, cls.update_db)
	-- skynet.timeout(100 * 60, cb)
end

function cls:afx( ... )
	-- body
	self._online = false
end

function cls:load_db_to_data()
	-- load user
	local sql = "select * from tg_users"
	local res = query.select("tg_users", sql)
	for k,v in pairs(res[1]) do
		if type(v) == "number" then
			assert(self._user[k]:dt() == field.data_type.integer or self._user[k]:dt() == field.data_type.biginteger)
			self._user[k].value = v
		end
	end
end

return cls