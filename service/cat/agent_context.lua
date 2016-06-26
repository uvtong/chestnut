local skynet = require "skynet"
local dc = require "datacenter"
local const = require "const"
local util = require "util"

local cls = class("agent_context")

function cls:ctor( ... )
	-- body
	self._host = false
	self._send_request = false
	self._gate = false
	self._userid = false
	self._subid = false
	self._secret = false
	self._db = false
	self._game = false
	self._user = false
	self._center = false

	local cls = require "notification_center"	
	local center = cls.new()
	self._center = center
	center:register(center.events.EGOLD, self.handler_egold, self)
	center:register(center.events.EEXP, self.handler_eexp, self)
	center:register(center.events.EUSER_LEVEL, self.handler_user_level, self)

	cls = require "load_user"
	local modelmgr = cls.new(self)
	self._modelmgr = modelmgr

	cls = require "factory"
	local myfactory = cls.new(self)
	self._myfactory = myfactory

	cls = require "helper"
	local helper = cls.new(self)
	self._helper = helper

	self._m = {}
	cls = require "arenamodule"
	local m = cls.new(self)
	self._m["arena"] = m
	cls = require "checkpointmodule"
	local m = cls.new(self)
	self._m["checkpoint"] = m
	cls = require "shopmodule"
	local m = cls.new(self)
	self._m["shop"] = m
	cls = require "rolemodule"
	local m = cls.new(self)
	self._m["role"] = m
	cls = require "rechargemodule"
	local m = cls.new(self)
	self._m["recharge"] = m
	cls = require "propmodule"
	local m = cls.new(self)
	self._m["prop"] = m
	cls = require "achievementmodule"
	local m = cls.new(self)
	self._m["achievement"] = m
	cls = require "usermodule"
	local m = cls.new(self)
	self._m["user"] = m
	cls = require "equipmentmodule"
	local m = cls.new(self)
	self._m["equipment"] = m
end

function cls:get_module(k, ... )
	-- body
	assert(type(k) == "string")
	return self._m[k]
end

function cls:get_helper( ... )
	-- body
	return self._helper
end

function cls:get_myfactory() 
	return self._myfactory
end

function cls:get_usersmgr( ... )
	-- body
	return self._usersmgr
end

function cls:get_modelmgr( ... )
	-- body
	return self._modelmgr
end

function cls:set_usersmgr(v, ... )
	-- body
	self._usersmgr = v
end

function cls:get_usersmgr( ... )
	-- body
	return self._usersmgr
end

function cls:get_myfactory( ... )
	-- body
	return self._myfactory
end

function cls:handler_egold( ... )
	-- body
	self:raise_achievement(const.ACHIEVEMENT_T_2)
end

function cls:handler_eexp( ... )
	-- body
 	self:raise_achievement(const.ACHIEVEMENT_T_3)
end

function cls:handler_user_level( ... )
	-- body
	self:raise_achievement(const.ACHIEVEMENT_T_7)
end

function cls:get_game( ... )
	-- body
	return self._game
end

function cls:set_game(v, ... )
	-- body
	self._game = v
end

function cls:get_notification( ... )
	-- body
	return self._center
end

function cls:get_host( ... )
	-- body
	return self._host
end

function cls:set_host(v)
	-- body
	if self._host == false then
		self._host = v
	end
end

function cls:get_send_request( ... )
	-- body
	return self._send_request
end

function cls:set_send_request(v)
	-- body
	self._send_request = true
end

function cls:get_gate( ... )
	-- body
	return self._gate
end

function cls:set_gate(v, ... )
	-- body
	self._gate = v
end

function cls:get_userid( ... )
	-- body
	return self._userid
end

function cls:set_userid(v, ... )
	-- body
	self._userid = v
end

function cls:get_subid( ... )
	-- body
	return self._subid
end

function cls:set_subid(v, ... )
	-- body
	self._subid = v
end

function cls:get_secret( ... )
	-- body
	return self._secret
end

function cls:set_secret(v, ... )
	-- body
	self._secret = v
end

function cls:get_db( ... )
	-- body
	return self._db
end

function cls:set_db(v, ... )
	-- body
	self._db = v
end

function cls:get_user( ... )
	-- body
	return self._user
end

function cls:set_user(v, ... )
	-- body
	self._user = v
end

function cls:raise_achievement(T)
	-- body 
	local m = self._m["achievement"]
	local ok, result = pcall(m.raise_achievement, m, T)
	if ok then
	else
		skynet.error(result)
	end
end

function cls:xilian(role, t)
	-- body
	local m = self._m["role"]
	local ok, result = pcall(m.xilian_, m, role, t)
	if ok then
	else
		skynet.error(result)
	end
end

function cls:role_recruit(csv_id)
	-- body
	local m = self._m["role"]
	local ok, result = pcall(m.role_recruit_, m, csv_id)
	if ok then
	else
		skynet.error(result)
	end
end

function cls:create_default(uid)
	-- body
	local factory = self._myfactory
	local user = factory:create_user(uid)
	return user
end

function cls:login( ... )
	-- body
	local u = self:get_user()
	local lp = skynet.getenv("leaderboards_name")
	skynet.call(lp, "lua", "push", u:get_field('csv_id'), u:get_field("csv_id"))

	local m = self._m["arena"]
	m:calculate_ara_role()

end

function cls:logout()
	-- body
	self:flush_db()
	
	local u = self:get_user()

	dc.set(u:get_field("csv_id"), "client_fd", client_fd)
	dc.set(u:get_field("csv_id"), "online", false)
	dc.set(u:get_field("csv_id"), "addr", 0)

	local gate = self._gate
	if gate then
		skynet.call(gate, "lua", "logout", self._userid, self._subid)
	end
	skynet.exit()
end

function cls:flush_db(priority)
	-- body
	local modelmgr = self._modelmgr
	local u = modelmgr:get_user()
	if u then
		for k,v in pairs(modelmgr._data) do
			-- print("#####################################################flush_db")
			v:update_db()
		end
	end
end

return cls
