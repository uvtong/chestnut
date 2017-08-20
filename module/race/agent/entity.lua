local assert = assert
local errorcode = require "errorcode"
local user = require "components.user"
local sysinbox = require "components.sysinbox"
local recordmgr = require "components.recordmgr"

local cls = class("entity")

function cls:ctor(env, uid, subid, ... )
	-- body
	self._env = env
	self._uid = uid
	self._subid = subid
	self._components = {}
	self:register_component()
end

function cls:get_component(name, ... )
	-- body
	return assert(self._components[name])
end

function cls:register_component( ... )
	-- body
	user.new(self)
	sysinbox.new(self)
	recordmgr.new(self)
end

function cls:load_cache_to_data( ... )
 	-- body
 	for k,v in pairs(self._components) do
 		v:load_cache_to_data()
 	end
end 

function cls:set_uid(uid, ... )
	-- body
	self._uid = uid
end

function cls:get_uid( ... )
	-- body
	return self._uid
end

function cls:set_subid(subid, ... )
	-- body
	self._subid = subid
end

function cls:get_subid( ... )
	-- body
	return self._subid
end

return cls