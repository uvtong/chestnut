local skynet = require "skynet"
local dc = require "datacenter"
local sd = require "sharedata"
local errorcode = require "errorcode"
local const = require "const"
local util = require "util"
local super = require "module"
local cls = class("usermodule", super)

function cls:ctor(env, ... )
	-- body
	self._env = env
end

function cls:user(args, ... )
	-- body
	local user = self._env:get_user()
	local modelmgr = self._env:get_modelmgr()
	local u_propmgr = modelmgr:get_u_propmgr()
	local factory = self._env:get_myfactory()
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg	= errorcode[2].msg
		return ret
	end
	assert(user)
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.user = {
		uname = user:get_field("uname"),
    	uviplevel = user:get_field("uviplevel"),
    	config_sound = (user:get_field("config_sound") == 1) and true or false,
    	config_music = (user:get_field("config_music") == 1) and true or false,
    	avatar = user:get_field("avatar"),
    	sign = user:get_field("sign"),
    	c_role_id = user:get_field("c_role_id"),
    	level = user:get_field("level"),
    	recharge_rmb = user:get_field("recharge_rmb"),
    	recharge_diamond = user:get_field("recharge_rmb"),
    	uvip_progress = user:get_field("uvip_progress"),
    	cp_hanging_id = user:get_field("cp_hanging_id"),
    	uexp = u_propmgr:get_by_csv_id(const.EXP):get_field("num"),
    	gold = u_propmgr:get_by_csv_id(const.GOLD):get_field("num"),
    	diamond = u_propmgr:get_by_csv_id(const.DIAMOND):get_field("num"),
    	love = u_propmgr:get_by_csv_id(const.LOVE):get_field("num"),
	}
	ret.user.equipment_list = {}
	local u_equipmentmgr = modelmgr:get_u_equipmentmgr()
	if u_equipmentmgr:get_count() > 0 then
		for k,v in pairs(u_equipmentmgr.__data) do
			local item = {}
			item.csv_id = v:get_field("csv_id")
			item.level = v:get_field("level")
			item.combat = v:get_field("combat")
			item.defense = v:get_field("defense")
			item.critical_hit = v:get_field("critical_hit")
			item.king = v:get_field("king")
			item.critical_hit_probability = v:get_field("critical_hit_probability")
			item.combat_probability = v:get_field("combat_probability")
			item.defense_probability = v:get_field("defense_probability")
			item.king_probability = v:get_field("king_probability")
			item.enhance_success_rate = v:get_field("enhance_success_rate")
			table.insert(ret.user.equipment_list, item)
		end
	else
		local item = {}
		item.csv_id = 0
		item.level = 0
		item.combat = 0
		item.defense = 0
		item.critical_hit = 0
		item.king = 0
		item.critical_hit_probability = 0
		item.combat_probability = 0
		item.defense_probability = 0
		item.king_probability = 0
		item.enhance_success_rate = 0
		table.insert(ret.user.equipment_list, item)
	end

	ret.user.kungfu_list = {}
	local u_kungfumgr = modelmgr:get_u_kungfumgr()
	if u_kungfumgr:get_count() > 0 then
		for k,v in pairs(u_kungfumgr.__data) do
			local item = {}
			item.csv_id = v:get_field("csv_id")
			item.k_level = v:get_field("level")
			item.k_type = v:get_field("type")
			item.k_sp_num = u_propmgr:get_by_csv_id(v:get_field("sp_id")):get_field("num")
			table.insert(ret.user.kungfu_list, item)
		end
	else
		local item = {}
		item.csv_id = 0
		item.k_level = 0
		item.k_type = 0
		item.k_sp_num = 0
		table.insert(ret.user.kungfu_list, item)
	end
	
	ret.user.rolelist = {}
	local u_rolemgr = modelmgr:get_u_rolemgr()
	if u_rolemgr:get_count() > 0 then
		for k,v in pairs(u_rolemgr.__data) do
			local item = {}
			item.csv_id = v:get_field("csv_id")
			item.is_possessed = true
			item.star = v:get_field("star")
			item.u_us_prop_num = factory:get_prop(v:get_field("us_prop_csv_id")):get_field("num")
			item.property_id1 = v:get_field("property_id1")
			item.value1 = v:get_field("value1")
			item.property_id2 = v:get_field("property_id2")
			item.value2 = v:get_field("value2")
			item.property_id3 = v:get_field("property_id3")
			item.value3 = v:get_field("value3")
			item.property_id4 = v:get_field("property_id4")
			item.value4 = v:get_field("value4")
			item.property_id5 = v:get_field("property_id5")
			item.value5 = v:get_field("value5")

			table.insert(ret.user.rolelist, item)
		end
	else
		local item = {}
		item.csv_id = 0
		item.is_possessed = false
		item.star = 0
		item.u_us_prop_num = 0
		item.property_id1 = 0
		item.value1 = 0
		item.property_id2 = 0
		item.value2 = 0
		item.property_id3 = 0
		item.value3 = 0
		item.property_id4 = 0
		item.value4 = 0
		item.property_id5 = 0
		item.value5 = 0
		table.insert(ret.user.rolelist, item)
	end
	local _1 = {}
	_1.uid = 0
	_1.uname = "tmp"
	_1.total_combat = 0
	_1.ranking = 0
	_1.iconid = 0
	_1.worship = false

	ret.ara_leaderboards = {}
	table.insert(ret.ara_leaderboards, _1)
	ret.ara_rmd_list = {}
	table.insert(ret.ara_rmd_list, _1)

	return ret
end

function cls:user_can_modify_name(args)
	-- body
	local user = self._env:get_user()
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	if user.modify_uname_count >= 1 then
		ret.errorcode = errorcode[17].code
		ret.msg = errorcode[17].msg
	else
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
	end
	return ret
end

function cls:user_modify_name(args)
	local user = self._env:get_user()
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg	= errorcode[2].msg
		return ret
	end
	if user.modify_uname_count >= 1 then
		local prop = user.u_propmgr:get_by_csv_id(const.DIAMOND)
		if prop.num >= 100 then
			prop:set_field("num", prop:get_field("num") - 100)
			prop:update_db({"num"})
			user:set_field("uname", args.name)
			user:set_field("modify_uname_count", user:get_field("modify_uname_count") + 1)
			user:update_db({"modify_uname_count", "uname"}, const.DB_PRIORITY_2)
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			return ret
		else
			ret.errorcode = errorcode[6].code
			ret.msg = errorcode[6].msg
			return ret
		end
	else
		user:set_field("uname", args.name)
		user:set_field("modify_uname_count", user:get_field("modify_uname_count") + 1)
		user:update_db({"modify_uname_count", "uname"}, const.DB_PRIORITY_2)
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		return ret
	end
end

function cls:user_upgrade(args)
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	local user_level_max
	local xilian_begain_level
	local ptr = skynet.call(game, "lua", "query_g_config")
	tptr.createtable(ptr)
	for _,k,v in tptr.pairs(ptr) do
		if k == "user_level_max" then
			user_level_max = v
		elseif k == "xilian_begain_level" then
			xilian_begain_level = v
		end
	end
	if user.level + 1 >= user_level_max then
		ret.errorcode = errorcode[30].code
		ret.msg = errorcode[30].msg
		return ret
	else
		local L = skynet.call(game, "lua", "query_g_user_level", user.level + 1)
		local prop = user.u_propmgr:get_by_csv_id(const.EXP)
		if prop.num >= tonumber(L.exp) then
			prop.num = prop.num - L.exp
			user.level = L.level
			user.combat = L.combat
			user.defense = L.defense
			user.critical_hit = L.critical_hit
			user.blessing = L.skill              -- blessing.
			user.gold_max = assert(L.gold_max)
			user.exp_max = assert(L.exp_max)
			if user.level >= xilian_begain_level then
				user.ifxilian = 1
			end
			ctx:raise_achievement(const.ACHIEVEMENT_T_7)
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			return ret
		else
			ret.errorcode = errorcode[19].code
			ret.msg	= errorcode[19].msg
			return ret
		end
	end
end

return cls
