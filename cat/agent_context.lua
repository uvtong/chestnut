local skynet = require "skynet"
require "skynet.manager"
local dc = require "datacenter"
local const = require "const"

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
	assert(T)
	while true do 
		local a = assert(self._user.u_achievementmgr:get_by_type(T))
		if a.unlock_next_csv_id == 0 then
			break
		end
		local finished
		if T == const.ACHIEVEMENT_T_2 then
			finished = self._user.u_propmgr:get_by_csv_id(const.GOLD).num
		elseif T == const.ACHIEVEMENT_T_3 then
			finished = self._user.u_propmgr:get_by_csv_id(const.EXP).num
		elseif T == const.ACHIEVEMENT_T_4 then
			finished = self._user.take_diamonds
		elseif T == const.ACHIEVEMENT_T_5 then
			finished = self._user.u_rolemgr:get_count()
		elseif T == const.ACHIEVEMENT_T_6 then
			finished = self._user.u_checkpointmgr:get_by_csv_id(0).chapter
		elseif T == const.ACHIEVEMENT_T_7 then
			finished = self._user.level
		elseif T == const.ACHIEVEMENT_T_8 then
			finished = self._user.draw_number
		elseif T == const.ACHIEVEMENT_T_9 then
			finished = self._user.u_kungfumgr:get_count()
		else
			assert(false)
		end
		local progress = finished / a.c_num
		if progress >= 1 then
			local tmp = {}
			for k,v in pairs(a) do
				tmp[k] = v
			end
			tmp.finished = 100
			tmp.reward_collected = 0
			self:push_achievement(a)

			local rc = self._user.u_achievement_rcmgr:create(tmp)
			self._user.u_achievement_rcmgr:add(rc)
			rc:__insert_db(const.DB_PRIORITY_2)

			assert(type(a.unlock_next_csv_id), string.format("%s", type(a.unlock_next_csv_id)))
			local ga = skynet.call(self._game, "lua", "query_g_achievement", a.unlock_next_csv_id)
			a.csv_id = ga.csv_id
			a.finished = 0
			a.c_num = ga.c_num
			a.unlock_next_csv_id = ga.unlock_next_csv_id
			a.is_unlock = 1
		else
			a.finished = math.floor(progress * 100)
			break
		end
	end
end

function cls:xilian(role, t)
	-- body
	assert(type(t) == "table")
	local ret = {}
	local property_pool = skynet.call(self._game, "lua", "query_g_property_pool")
	local last = 0
	local sum = 0
	for k,v in pairs(property_pool) do
		v.min = last
		sum = sum + v.probability
		v.max = sum
	end
	local n = 0
	if t.is_locked1 then
		n = n + 1
		ret.property_id1 = role.property_id1
		ret.value1 = role.value1
	else
		local property_pool_id
		local rand = math.random(0, sum-1)
		for k,v in pairs(property_pool) do
			if rand >= v.min and rand < v.max then
				property_pool_id = v.property_pool_id
				break
			end
		end
		assert(property_pool_id)
		property_pool_id = 1
		local last1 = 0
		local sum1 = 0
		local second = skynet.call(self._game, "lua", "query_g_property_pool_second", 0, property_pool_id)
		for i,v in ipairs(second) do
			v.min = last1
			sum1 = sum1 + v.probability
			v.max = sum1
		end
		rand = math.random(0, sum1-1)
		for i,v in ipairs(second) do
			if rand >= v.min and rand < v.max then
				ret.property_id1 = v.property_id
				ret.value1 = v.value
				break
			end
		end
	end

	if t.is_locked2 then
		n = n + 1
		ret.property_id2 = role.property_id2
		ret.value2 = role.value2
	else
		local property_pool_id
		local rand = math.random(0, sum-1)
		for k,v in pairs(property_pool) do
			if rand >= v.min and rand < v.max then
				property_pool_id = v.property_pool_id
				break
			end
		end
		assert(property_pool_id)
		property_pool_id = 1
		local last1 = 0
		local sum1 = 0
		local second = skynet.call(self._game, "lua", "query_g_property_pool_second", 0, property_pool_id)
		for i,v in ipairs(second) do
			v.min = last1
			sum1 = sum1 + v.probability
			v.max = sum1
		end
		rand = math.random(0, sum1-1)
		for i,v in ipairs(second) do
			if rand >= v.min and rand < v.max then
				ret.property_id2 = v.property_id
				ret.value2 = v.value
				break
			end
		end
	end

	if t.is_locked3 then
		n = n + 1
		ret.property_id3 = role.property_id3
		ret.value3 = role.value3
	else
		local property_pool_id
		local rand = math.random(0, sum-1)
		for k,v in pairs(property_pool) do
			if rand >= v.min and rand < v.max then
				property_pool_id = v.property_pool_id
				break
			end
		end
		assert(property_pool_id)
		property_pool_id = 1
		local last1 = 0
		local sum1 = 0
		local second = skynet.call(self._game, "lua", "query_g_property_pool_second", 0, property_pool_id)
		for i,v in ipairs(second) do
			v.min = last1
			sum1 = sum1 + v.probability
			v.max = sum1
		end
		rand = math.random(0, sum1-1)
		for i,v in ipairs(second) do
			if rand >= v.min and rand < v.max then
				ret.property_id3 = v.property_id
				ret.value3 = v.value
				break
			end
		end
	end

	if t.is_locked4 then
		n = n + 1
		ret.property_id4 = role.property_id4
		ret.value4 = role.value4
	else
		local property_pool_id
		local rand = math.random(0, sum-1)
		for k,v in pairs(property_pool) do
			if rand >= v.min and rand < v.max then
				property_pool_id = v.property_pool_id
				break
			end
		end
		assert(property_pool_id)
		property_pool_id = 1
		local last1 = 0
		local sum1 = 0
		local second = skynet.call(self._game, "lua", "query_g_property_pool_second", 0, property_pool_id)
		for i,v in ipairs(second) do
			v.min = last1
			sum1 = sum1 + v.probability
			v.max = sum1
		end
		rand = math.random(0, sum1-1)
		for i,v in ipairs(second) do
			if rand >= v.min and rand < v.max then
				ret.property_id4 = v.property_id
				ret.value4 = v.value
				break
			end
		end
	end

	if t.is_locked5 then
		n = n + 1
		ret.property_id5 = role.property_id5
		ret.value5 = role.value5
	else
		local property_pool_id
		local rand = math.random(0, sum-1)
		for k,v in pairs(property_pool) do
			if rand >= v.min and rand < v.max then
				property_pool_id = v.property_pool_id
				break
			end
		end
		assert(property_pool_id)
		property_pool_id = 1
		local last1 = 0
		local sum1 = 0
		local second = skynet.call(self._game, "lua", "query_g_property_pool_second", 0, property_pool_id)
		for i,v in ipairs(second) do
			v.min = last1
			sum1 = sum1 + v.probability
			v.max = sum1
		end
		rand = math.random(0, sum1-1)
		for i,v in ipairs(second) do
			if rand >= v.min and rand < v.max then
				ret.property_id5 = v.property_id
				ret.value5 = v.value
				break
			end
		end
	end
	return n, ret
end

function cls:role_recruit(csv_id)
	-- body
	assert(csv_id)
	local role = skynet.call(".game", "lua", "query_g_role", csv_id)
	local us = skynet.call(".game", "lua", "query_g_role_star", role.csv_id*1000 + role.star)
	local prop = self._user.u_propmgr:get_by_csv_id(role.us_prop_csv_id)
	if prop and prop.num >= assert(us.us_prop_num) then
		prop.num = prop.num - us.us_prop_num
		role.user_id = self._user.csv_id
		for k,v in pairs(us) do
			role[k] = v
		end
		role.k_csv_id1 = 0
		role.k_csv_id2 = 0
		role.k_csv_id3 = 0
		role.k_csv_id4 = 0
		role.k_csv_id5 = 0
		role.k_csv_id6 = 0
		role.k_csv_id7 = 0
		if self._user.ifxilian == 1 then
			local n, r = self.xilian(role, {role_id=role.csv_id, is_locked1=false, is_locked2=false, is_locked3=false, is_locked4=false, is_locked5=false})
			assert(n == 0, string.format("%d locked.", n))
			role.property_id1 = r.property_id1
			role.value1 = r.value1
			role.property_id2 = r.property_id2
			role.value2 = r.value2
			role.property_id3 = r.property_id3
			role.value3 = r.value3
			role.property_id4 = r.property_id4
			role.value4 = r.value4
			role.property_id5 = r.property_id5
			role.value5 = r.value5
		else
			role.property_id1 = 0
			role.value1 = 0
			role.property_id2 = 0
			role.value2 = 0
			role.property_id3 = 0
			role.value3 = 0
			role.property_id4 = 0
			role.value4 = 0
			role.property_id5 = 0
			role.value5 = 0
		end
		role = self._user.u_rolemgr.create(role)
		self._user.u_rolemgr:add(role)
		role:__insert_db(const.DB_PRIORITY_2)
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
	skynet.call(lp, "lua", "push", u:get_field('csv_id'), u:get_field("sum_combat"))
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
			v:update_db()
		end
	end
end

return cls
