local skynet = require "skynet"
local log = require "skynet.log"
local redis = require "skynet.db.redis"
local context = require "context"
local errorcode = require "errorcode"

local assert = assert
local pcall = skynet.pcall

local cls = class("acontext", context)

function cls:ctor( ... )
	-- body
	cls.super.ctor(self, ...)
	self._reload = false
	self._db = nil
	self._modules = {}

	return self
end

function cls:get_reload( ... )
	-- body
	return self._reload
end

function cls:set_reload(value, ... )
	-- body
	self._reload = value
end

function cls:get_db( ... )
	-- body
	return self._db
end

function cls:set_db(value, ... )
	-- body
	self._db = value
	for _,M in pairs(self._modules) do
		M:set_db(value)
	end
end

function cls:login(gate, uid, subid, secret)

	local cache_host = skynet.getenv "cache_host"
	local cache_port = skynet.getenv "cache_port"
	local cache_db   = skynet.getenv "cache_db"

	local conf = {
		host = cache_host,
		port = cache_port,
		db = cache_db
	}

	local db = redis.connect(conf)
	self._db = db

	if self._reload then
		cls.super.login(self, gate, uid, subid, secret)

		for _,M in pairs(self._modules) do
			M:login()
		end
	
		self:load_cache_to_data()
	end
end

function cls:logout( ... )
	-- body
	cls.super.logout(self)

	for _,M in pairs(self._modules) do
		M:logout()
	end

	self._db:disconnect()
	
end

function cls:authed( ... )
	-- body
	for _,M in pairs(self._modules) do
		M:authed()
	end
end

function cls:afk( ... )
	-- body
	for _,M in pairs(self._modules) do
		M:afk()
	end
end

function cls:load_cache_to_data()
	-- load user
	for _,M in pairs(self._modules) do
		M:load_cache_to_data()
	end
end

function cls:register_module(name, m, ... )
	-- body
	self._modules[name] = m
end

return cls