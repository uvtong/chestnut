local skynet = require "skynet"
local field = require "db.field"
local entity = require "db.entity"
local query = require "query"
local log = require "log"
local dbmonitor = require "dbmonitor"

local cls = class("sysmail", entity)

function cls:ctor(env, dbctx, set, ... )
	-- body
	cls.super.ctor(self, env, dbctx, set)

	self.id       = field.new(self, "id", 1, field.data_type.integer)
	self.uid      = field.new(self, "uid", 2, field.data_type.integer)
	self.mailid   = field.new(self, "mailid", 3, field.data_type.integer)
	self.viewed   = field.new(self, "viewed", 5, field.data_type.integer)
end

function cls:key( ... )
	-- body
	return string.format("tu_sysmail:%d:%d", self.uid.value, self.id.value)
end

function cls:set_id(value, ... )
	-- body
	self.id:set_value(value)
end

function cls:set_uid(value, ... )
	-- body
	self.uid:set_value(value)
end

function cls:set_mailid(value, ... )
	-- body
	self.mailid:set_value(value)
end

function cls:set_datetime(value, ... )
	-- body
	self.datetime:set_value(value)
end

function cls:set_viewed(value, ... )
	-- body
	self.viewed:set_value(value)

	skynet.fork(function (key, val, ... )
		-- body
		self._env._db:hset(self:key(), key, val)
		dbmonitor.cache_update(self:key(), key)
	end, 'viewed', value)
end

function cls:load_cache_to_data( ... )
	-- body
	local vals = self._env._db:hgetall(self:key())

	local t = {}
	for i=1,#vals,2 do
		t[vals[i]] = vals[i+1]
	end

	self.mailid.value   = math.tointeger(t.mailid)
	self.viewed.value   = math.tointeger(t.viewed)

	self:print_info()
end

function cls:insert_cache( ... )
	-- body
	skynet.fork(function ( ... )
		-- body
		self._env._db:zadd(string.format('tb_user_sysmail:%s', self.uid.value), 1, self.id.value)
		for k,v in pairs(self._fields) do
			-- print(v.name, v.value)
			self._env._db:hset(string.format('tb_user_sysmail:%d:%d', self.uid.value, self.id.value), v.name, v.value)
		end
		dbmonitor.cache_insert(string.format('tb_user_sysmail:%d:%d', self.uid.value, self.id.value))
	end)
end

return cls