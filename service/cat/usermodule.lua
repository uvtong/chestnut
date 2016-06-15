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

	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg	= errorcode[2].msg
		return ret
	end
	
	-- assert(u_propmgr == user.u_propmgr)
	assert(u_propmgr:get_user() == user)
	assert(user)
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.user = {
		uname = user.uname,
    	uviplevel = user.uviplevel,
    	config_sound = (user.config_sound == 1) and true or false,
    	config_music = (user.config_music == 1) and true or false,
    	avatar = user.avatar,
    	sign = user.sign,
    	c_role_id = user.c_role_id,
    	level = user.level,
    	recharge_rmb = user.recharge_rmb,
    	recharge_diamond = user.recharge_diamond,
    	uvip_progress = user.uvip_progress,
    	cp_hanging_id = user.cp_hanging_id,
    	uexp = assert(user.u_propmgr:get_by_csv_id(const.EXP)).num,
    	gold = assert(user.u_propmgr:get_by_csv_id(const.GOLD)).num,
    	diamond = assert(user.u_propmgr:get_by_csv_id(const.DIAMOND)).num,
    	love = assert(user.u_propmgr:get_by_csv_id(const.LOVE)).num,
	}
	ret.user.equipment_list = {}
	for k,v in pairs(user.u_equipmentmgr.__data) do
		table.insert(ret.user.equipment_list, v)
	end
	ret.user.kungfu_list = {}
	for k,v in pairs(user.u_kungfumgr.__data) do
		table.insert(ret.user.kungfu_list, v)
	end
	print("called****************************444")
	ret.user.rolelist = {}
	for k,v in pairs(user.u_rolemgr.__data) do
		table.insert(ret.user.rolelist, v)
	end
	print("called****************************555")
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
