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
end

function cls:role_recruit(args)
	-- body
	local ret = {}
	local user = self._env:get_user()
	local game = self._env:get_game()
	local modelmgr = self._env:get_modelmgr()
	if not ret then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user.u_rolemgr:get_by_csv_id(args.csv_id) == nil)
	local key = string.format("%s:%d", "g_role", args.csv_id)
	local role = sd.query(key)
	local key = string.format("%s:%d", "g_role_star", role.csv_id*1000 + role.star)
	local us = sd.query(key)
	
	local prop = user.u_propmgr:get_by_csv_id(role.us_prop_csv_id)
	if prop and prop.num >= assert(us.us_prop_num) then

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
		if user.ifxilian == 1 then
			local n, r = self._env:xilian(role, {role_id=role.csv_id, is_locked1=false, is_locked2=false, is_locked3=false, is_locked4=false, is_locked5=false})
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
		role.id = genpk_2(role.user_id, role.csv_id)
		role = user.u_rolemgr:create(role)
		user.u_rolemgr:add(role)
		role:update_db()

		if user:get_field("ara_role_id1") == 0 then
			user:set_field("ara_role_id1", role:get_field("csv_id"))
		elseif user:get_field("ara_role_id2") == 0 then
			user:set_field("ara_role_id2", role:get_field("csv_id"))
		elseif user:get_field("ara_role_id3") == 0 then
			user:set_field("ara_role_id3", role:get_field("csv_id"))
		end
		self._env:raise_achievement(const.ACHIEVEMENT_T_5)

		prop:set_field("num", prop:get_field("num") - us.us_prop_num)
		prop:update_db()

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

return cls
