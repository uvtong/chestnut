local skynet = require "skynet"
local dc = require "datecenter"
local cls = class("arena")

function cls:ctor(env, ... )
	-- body
	self._env = env
	self._me = false
	self._enemy = false
	self._me_modelmgr = false
	self._en_modelmgr = false
	return self
end

function cls:set_me(v, ... )
	-- body
	self._me = v
end

function cls:set_enemy(v, ... )
	-- body
	self._enemy = v
end

function cls:get_me( ... )
	-- body
	return self._me
end

function cls:get_enemy( ... )
	-- body
	return self._enemy
end

function cls:set_me_modelmgr(v, ... )
	-- body
	self._me_modelmgr = v
end

function cls:get_me_modelmgr( ... )
	-- body
	return self._me_modelmgr
end

function cls:set_en_modelmgr(v, ... )
	-- body
	self._en_modelmgr = v
end

function cls:get_en_modelmgr( ... )
	-- body
	return self._en_modelmgr
end

function cls:load_enemy(uid, ... )
	-- body
	if dc.get(uid, "online") then
		local modelmgr_cls = require "load_user"
		local modelmgr = modelmgr_cls.new()
		local addr = dc.get(uid, "addr")
		local r = skynet.call(addr, "lua", "ara_user")
		modelmgr:load_remote(uid, r)
		local user = modelmgr:get_user("user")
		self:set_enemy(user)
		self:set_en_modelmgr(modelmgr)
	else
		local modelmgr_cls = require "load_user"
		local modelmgr = modelmgr_cls.new()
		modelmgr:load1(uid)
		local user = modelmgr:get_user("user")
		self:set_enemy(user)
		self:set_en_modelmgr(modelmgr)
	end
end

return cls