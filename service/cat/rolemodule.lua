local skynet = require "skynet"
local dc = require "datacenter"
local sd = require "sharedata"
local errorcode = require "errorcode"
local const = require "const"
local util = require "util"
local super = require "module"
local cls = class("arenamodule", super)

function cls:ctor(env, ... )
	-- body
	self._env = env
	self._xilian_lock = 0
	self._xilian_role_id = 0
end

function cls:xilian_(role, t)
	-- body
	assert(type(t) == "table")
	local game = self._env:get_game()
	local property_pool = skynet.call(game, "lua", "query_g_property_pool")
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
		local second = skynet.call(game, "lua", "query_g_property_pool_second", 0, property_pool_id)
		for i,v in ipairs(second) do
			v.min = last1
			sum1 = sum1 + v.probability
			v.max = sum1
		end
		rand = math.random(0, sum1-1)
		for i,v in ipairs(second) do
			if rand >= v.min and rand < v.max then
				role:set_field("property_id1", v.property_id1)
				role:set_field("value1", v.value)
				break
			end
		end
	end

	if t.is_locked2 then
		n = n + 1
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
		local second = skynet.call(game, "lua", "query_g_property_pool_second", 0, property_pool_id)
		for i,v in ipairs(second) do
			v.min = last1
			sum1 = sum1 + v.probability
			v.max = sum1
		end
		rand = math.random(0, sum1-1)
		for i,v in ipairs(second) do
			if rand >= v.min and rand < v.max then
				role:set_field("property_id2", v.property_id)
				role:set_field("value2", v.value)
				break
			end
		end
	end

	if t.is_locked3 then
		n = n + 1
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
				role:set_field("property_id3", v.property_id)
				role:set_field("value3", v.value)
				break
			end
		end
	end

	if t.is_locked4 then
		n = n + 1
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
				role:set_field("property_id4", v.property_id)
				role:set_field("value4", v.value)
				break
			end
		end
	end

	if t.is_locked5 then
		n = n + 1
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
				role:set_field("property_id5", v.property_id)
				role:set_field("value5", v.value)
				break
			end
		end
	end
	return n
end

function cls:role_recruit_(csv_id)
	-- body
	local user = self._env:get_user()
	local modelmgr = self._env:get_modelmgr()
	local u_propmgr = modelmgr:get_u_propmgr()
	local u_rolemgr = modelmgr:get_u_propmgr()
	local factory = self._env:get_myfactory()

	assert(u_rolemgr:get_by_csv_id(csv_id) == nil)
	local key = string.format("%s:%d", "g_role", args.csv_id)
	local role = sd.query(key)
	local key = string.format("%s:%d", "g_role_star", role.csv_id*1000 + role.star)
	local us = sd.query(key)
	
	local prop = factory:get_prop(role.us_prop_csv_id)
	if prop:get_field("num") >= assert(us.us_prop_num) then
		local tmp = {}
		for k,v in pairs(role) do
			tmp[k] = v
		end
		for k,v in pairs(us) do
			tmp[k] = v
		end

		tmp.user_id = self._env:get_userid()
		tmp.id = genpk_2(tmp.user_id, tmp.csv_id)
		tmp.k_csv_id1 = 0
		tmp.k_csv_id2 = 0
		tmp.k_csv_id3 = 0
		tmp.k_csv_id4 = 0
		tmp.k_csv_id5 = 0
		tmp.k_csv_id6 = 0
		tmp.k_csv_id7 = 0

		tmp.property_id1 = 0
		tmp.value1 = 0
		tmp.property_id2 = 0
		tmp.value2 = 0
		tmp.property_id3 = 0
		tmp.value3 = 0
		tmp.property_id4 = 0
		tmp.value4 = 0
		tmp.property_id5 = 0
		tmp.value5 = 0

		local entity = u_rolemgr:create_entity(tmp)
		u_rolemgr:add(entity)
		entity:update_db()

		local n = self:xilian_(entity, {role_id=role.csv_id, is_locked1=false, is_locked2=false, is_locked3=false, is_locked4=false, is_locked5=false})

		if user:get_field("ara_role_id1") == 0 then
			user:set_field("ara_role_id1", entity:get_field("csv_id"))
		elseif user:get_field("ara_role_id2") == 0 then
			user:set_field("ara_role_id2", entity:get_field("csv_id"))
		elseif user:get_field("ara_role_id3") == 0 then
			user:set_field("ara_role_id3", entity:get_field("csv_id"))
		end
		self._env:raise_achievement(const.ACHIEVEMENT_T_5)

		prop:set_field("num", prop:get_field("num") - us.us_prop_num)
		prop:update_db()
		return true, entity
	else
		return false
	end
end

function cls:role_recruit(args)
	-- body
	local modelmgr = self._env:get_modelmgr()
	local u_propmgr = modelmgr:get_u_propmgr()
	local ok, role = self.role_recruit_(args.csv_id)
	if ok then
		local prop = u_propmgr:get_by_csv_id(role:get_field("us_prop_csv_id"))
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		ret.r = {
			csv_id = role.csv_id,
			is_possessed = true,
			star = role.star,
			u_us_prop_num = prop:get_field("num")
		}
		return ret
	else
		ret.errorcode = errorcode[3].code
		ret.msg = errorcode[3].msg
		return ret
	end
end

function cls:role_battle(args)
	-- body
	local user = self._env:get_user()
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user.u_rolemgr:get_by_csv_id(args.csv_id))
	user:set_field("c_role_id", args.csv_id)
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	return ret
end

function cls:role_all(args)
	-- body
	local ret = {}
	local user = self._env:get_user()
	local game = self._env:get_game()
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	local l = {}
	local r = skynet.call(game, "lua", "query_g_role")
	for k,v in pairs(r) do
		local item = {}
		item.csv_id = v.csv_id
		item.star = v.star
		item.u_us_prop_num = v.u_us_prop_num
		local role = user.u_rolemgr:get_by_csv_id(v.csv_id)
		if role then
			item.is_possessed = true
			item.property_id1 = role.property_id1
			item.value1       = role.value1
			item.property_id2 = role.property_id2
			item.value2       = role.value2
			item.property_id3 = role.property_id3
			item.value3       = role.value3
			item.property_id4 = role.property_id4
			item.value4       = role.value4
			item.property_id5 = role.property_id5
			item.value5       = role.value5
		else
			item.is_possessed = false
			item.property_id1 = 0
			item.value1       = 0
			item.property_id2 = 0
			item.value2       = 0
			item.property_id3 = 0
			item.value3       = 0
			item.property_id4 = 0
			item.value4       = 0
			item.property_id5 = 0
			item.value5       = 0
		end

		local prop = user.u_propmgr:get_by_csv_id(v.us_prop_csv_id)
		if prop then
			item.u_us_prop_num = prop:get_field("num")
		else
			item.u_us_prop_num = 0
		end
		table.insert(l, item)
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.l = l
    return ret
end

function cls:role_info(args)
	local user = self._env:get_user()
	local modelmgr = self._env:get_modelmgr()
	local u_propmgr = modelmgr:get_u_propmgr()
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	if args.role_id == nil then
		ret.errorcode = errorcode[27].code
		ret.msg = errorcode[27].msg
		return ret
	end
	local role = assert(user.u_rolemgr:get_by_csv_id(self.role_id))
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	local r = {}
	r.csv_id = role:get_field("csv_id")
	r.is_possessed = true
	r.star = role:get_field("star")
	r.u_us_prop_num = role:get_field("u_us_prop_num")
	r.property_id1 = role:get_field("property_id1")
	r.value1       = role:get_field("value1")
	r.property_id2 = role:get_field("property_id2")
	r.value2       = role:get_field("value2")
	r.property_id3 = role:get_field("property_id3")
	r.value3       = role:get_field("value3")
	r.property_id4 = role:get_field("property_id4")
	r.value4       = role:get_field("value4")
	r.property_id5 = role:get_field("property_id5")
	r.value5       = role:get_field("value5")
	local prop = u_propmgr:get_by_csv_id(role:get_field("us_prop_csv_id"))
	if prop then
		r.u_us_prop_num = prop:get_field("num")
	else
		r.u_us_prop_num = 0
	end
	ret.r = r
	return ret
end	

function cls:role_upgrade_star(args, ... )
	-- body
	local user = self._env:get_user()
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(self.role_csv_id)
	local role = assert(user.u_rolemgr:get_by_csv_id(self.role_csv_id))
	local prop = user.u_propmgr:get_by_csv_id(role.us_prop_csv_id)
	local role_star = skynet.call(game, "lua", "query_g_role_star", role.csv_id*1000+role.star+1)
	if prop and prop.num >= role_star.us_prop_num then
		prop.num = prop.num - role_star.us_prop_num
		prop:update_db({"num"})
		role.star = role_star.star
		-- role.us_prop_csv_id = assert(role_star.us_prop_csv_id)
		role.us_prop_num = assert(role_star.us_prop_num)
		role.sharp = assert(role_star.sharp)
		role.skill_csv_id = assert(role_star.skill_csv_id)
		role.gather_buffer_id = assert(role_star.gather_buffer_id)
		role.battle_buffer_id = assert(role_star.battle_buffer_id)
		role:update_db({"star", "us_prop_num", "sharp", "skill_csv_id", "gather_buffer_id", "battle_buffer_id"})
		-- return
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		ret.r = {
			csv_id = role.csv_id,
			is_possessed = true,
			star = role.star,
    		u_us_prop_num = prop.num
		}
		return ret
	else
		ret.errorcode = errorcode[3].code
		ret.msg = errorcode[3].msg
		return ret
	end
end

function cls:xilian(args)
	-- body
	local user = self._env:get_user()
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
 		ret.msg = errorcode[2].msg
 		return ret
	end
	self._xilian_lock = 0
	self._xilian_role_id = args.role_id
	local role = user.u_rolemgr:get_by_csv_id(self._xilian_role_id)
	local n, r = self:xilian_(role, args)
	assert(n >= 0)
	local xilian_cost = skynet.call(game, "lua", "query_g_xilian_cost", n)
	assert(type(xilian_cost.cost) == "string")
	local C = util.parse_text(xilian_cost.cost, "(%d+%*%d+%*?)", 2)
	for i,v in ipairs(C) do
		local prop = user.u_propmgr:get_by_csv_id(v[1])
		if prop.num < tonumber(v[2]) then
			ret.errorcode = errorcode[31].code
			ret.msg = errorcode[31].msg	
			return ret
		end
	end
	for i,v in ipairs(C) do
		local prop = user.u_propmgr:get_by_csv_id(v[1])
		prop.num = prop.num - tonumber(v[2])
	end
	self._xilian_lock = 1
	-- if type(role.backup) ~= "table" then
	-- 	role.backup = {}
	-- end
	role.backup = r
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	for k,v in pairs(r) do
		ret[k] = v
	end
	return ret
end

function cls:xilian_ok()
	-- body
	local ret = {}
	if not user then
 		ret.errorcode = errorcode[2].code
 		ret.msg = errorcode[2].msg
 		return ret
 	end
 	if xilian_lock ~= 1 then
 		ret.errorcode = errorcode[32].code
 		ret.msg = errorcode[32].msg
 		return ret
 	else
 		xilian_lock = 1
 	end
	if self.ok then
		assert(self.role_id == xilian_role_id, "must be equip")
		local role = user.u_rolemgr:get_by_csv_id(self.role_id)
		assert(role.backup)
		role.property_id1 = role.backup.property_id1
		role.value1 = role.backup.value1
		role.property_id2 = role.backup.property_id2
		role.value2 = role.backup.value2
		role.property_id3 = role.backup.property_id3
		role.value3 = role.backup.value3
		role.property_id4 = role.backup.property_id4
		role.value4 = role.backup.value4
		role.property_id5 = role.backup.property_id5
		role.value5 = role.backup.value5
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		return ret
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	return ret
end   

return cls