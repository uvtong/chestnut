local skynet = require "skynet"
local const = require "const"
local _M = {}

_M.WATCHDOG = nil
_M.host = nil
_M.send_request = nil

_M.client_fd = nil

_M.game = nil
_M.user = nil

function _M:init( ... )
 	-- body
end

function _M:send_package(pack)
	-- body
	local package = string.pack(">s2", pack)
	socket.write(self.client_fd, package)
end

function _M:push_achievement(achievement)
	-- body
	ret = {}
	ret.which = {
		csv_id = achievement.csv_id,
		finished = achievement.finished
	}
	-- self:send_package(self.send_request("finish_achi", ret))
end

function _M:raise_achievement(T)
	-- body
	assert(T)
	while true do 
		local a = assert(self.user.u_achievementmgr:get_by_type(T))
		if a.unlock_next_csv_id == 0 then
			break
		end
		local finished
		if T == const.ACHIEVEMENT_T_2 then
			finished = self.user.u_propmgr:get_by_csv_id(const.GOLD).num
		elseif T == const.ACHIEVEMENT_T_3 then
			finished = self.user.u_propmgr:get_by_csv_id(const.EXP).num
		elseif T == const.ACHIEVEMENT_T_4 then
			finished = self.user.take_diamonds
		elseif T == const.ACHIEVEMENT_T_5 then
			finished = self.user.u_propmgr:get_count()
		elseif T == const.ACHIEVEMENT_T_6 then
			finished = self.user.u_checkpointmgr:get_by_csv_id(0).chapter
		elseif T == const.ACHIEVEMENT_T_7 then
			finished = self.user.level
		elseif T == const.ACHIEVEMENT_T_8 then
			finished = self.user.draw_number
		elseif T == const.ACHIEVEMENT_T_9 then
			finished = self.user.u_kungfumgr:get_count()
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

			local rc = self.user.u_achievement_rcmgr.create(tmp)
			self.user.u_achievement_rcmgr:add(rc)
			rc:__insert_db(const.DB_PRIORITY_2)

			assert(type(a.unlock_next_csv_id), string.format("%s", type(a.unlock_next_csv_id)))
			local ga = skynet.call(self.game, "lua", "query_g_achievement", a.unlock_next_csv_id)
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

function _M:xilian(role, t)
	-- body
	assert(type(t) == "table")
	local ret = {}
	local property_pool = skynet.call(self.game, "lua", "query_g_property_pool")
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
		local second = skynet.call(self.game, "lua", "query_g_property_pool_second", 0, property_pool_id)
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
		local second = skynet.call(self.game, "lua", "query_g_property_pool_second", 0, property_pool_id)
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
		local second = skynet.call(self.game, "lua", "query_g_property_pool_second", 0, property_pool_id)
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
		local second = skynet.call(self.game, "lua", "query_g_property_pool_second", 0, property_pool_id)
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
		local second = skynet.call(self.game, "lua", "query_g_property_pool_second", 0, property_pool_id)
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

function _M:role_recruit(csv_id)
	-- body
	assert(user.u_rolemgr:get_by_csv_id(self.csv_id) == nil)
	local role = skynet.call(self.game, "lua", "query_g_role", csv_id)
	local us = skynet.call(self.game, "lua", "query_g_role_star", role.csv_id*1000 + role.star)
	local prop = user.u_propmgr:get_by_csv_id(role.us_prop_csv_id)
	if prop and prop.num >= assert(us.us_prop_num) then
		prop.num = prop.num - us.us_prop_num
		role.user_id = user.csv_id
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
		if self.user.ifxilian == 1 then
			local n, r = self:xilian(role, {role_id=role.csv_id, is_locked1=false, is_locked2=false, is_locked3=false, is_locked4=false, is_locked5=false})
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
		role = user.u_rolemgr.create(role)
		user.u_rolemgr:add(role)
		role:__insert_db(const.DB_PRIORITY_2)
		self:raise_achievement(const.ACHIEVEMENT_T_5)
	end
end

function _M:add_gold(num)
	-- body
	local prop = self.user.u_propmgr:get_by_csv_id(const.GOLD)
	prop.num = prop.num + num
end

function _M:add_diamond(num)
	-- body
	local prop = self.user.u_propmgr:get_by_csv_id(const.DIAMOND)
	prop.num = prop.num + num
end

function _M:add_exp(num)
	-- body
	local prop = self.user.u_propmgr:get_by_csv_id(const.EXP)
	prop.num = prop.num + num
end

function _M:add_love(num)
	-- body
	local prop = self.user.u_propmgr:get_by_csv_id(const.EXP)
	prop.num = prop.num + num
end

return _M
