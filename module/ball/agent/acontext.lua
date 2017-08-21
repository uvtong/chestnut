local skynet = require "skynet"
local log = require "skynet.log"
local context = require "context"
local errorcode = require "errorcode"

local assert = assert
local pcall = skynet.pcall

local cls = class("acontext", context)

function cls:ctor( ... )
	-- body
	cls.super.ctor(self, ...)
	self._db = nil
	self._modules = {}
	return self
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

	cls.super.login(self, gate, uid, subid, secret)

	for _,M in pairs(self._modules) do
		M:login()
	end
	
	self:load_cache_to_data()
end

function cls:logout( ... )
	-- body
	cls.super.logout(self)

	for _,M in pairs(self._modules) do
		M:logout()
	end
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