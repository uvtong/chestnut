local skynet = require "skynet"
local dc = require "datacenter"
local sd = require "sharedata"
local errorcode = require "errorcode"
local const = require "const"
local util = require "util"
local super = require "module"
local cls = class("rechargemodule", super)

function cls:ctor(env, ... )
	-- body
	self._env = env
end

function cls:recharge_vip_reward_all(args)
	-- body
	local ret = {}
	local user = self._env:get_user()
	local game = self._env:get_game()
	local modelmgr = self._env:get_modelmgr()
	local u_recharge_vip_rewardmgr = modelmgr:get_u_recharge_vip_rewardmgr()
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	local a = skynet.call(game, "lua", "query_g_recharge_vip_reward")
	local l = {}
	for k,v in pairs(a) do
		local item = {}
		item.vip   = v.vip
		item.props = {}
		local r = util.parse_text(v.rewared, "%d+%*%d+%*?", 2)
		for i,vv in ipairs(r) do
			table.insert(item.props, { csv_id=vv[1], num=vv[2]})
		end
		local reward = user.u_recharge_vip_rewardmgr:get_by_vip(v.vip)
		if reward then
			item.collected = (reward.collected == 1) and true or false
			item.purchased = (reward.purchased == 1) and true or false
		else
			local tmp = {}
			tmp.user_id = user:get_field("csv_id")
			tmp.vip = v.vip
			tmp.collected = 0
			tmp.purchased = 0
			tmp.id = genpk_2(tmp.user_id, tmp.vip)
			local entity = u_recharge_vip_rewardmgr:create_entity(tmp)
			u_recharge_vip_rewardmgr:add(entity)
			entity:update_db()
			item.collected = false
			item.purchased = false
		end
		table.insert(l, item)
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.reward = l
	return ret
end

function cls:recharge_purchase(args)
	-- body
	local user = self._env:get_user()
	local game = self._env:get_game()
	local modelmgr = self._env:get_modelmgr()
	local u_propmgr = modelmgr:get_u_propmgr()
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	-- success
	if true then
		local v = args.g[1]	
		local goods = skynet.call(game, "lua", "query_g_recharge", v.csv_id)
		user:set_field("recharge_rmb", user.recharge_rmb + goods.rmb * v.num)
		user:set_field("recharge_diamond", user.recharge_diamond + goods.diamond * v.num)
		user:update_db({"recharge_rmb", "recharge_diamond"}, const.DB_PRIORITY_2)
		-- 
		local rc = user.u_recharge_countmgr:get_by_csv_id(v.csv_id)
		if rc then
			rc:set_field("count", rc.count + 1)
			rc:update_db({"count"})
		else
			local tmp = {}
			tmp.user_id = user:get_field('csv_id')
			tmp.csv_id = v.csv_id
			tmp.id = genpk_2(tmp.user_id, tmp.csv_id)
			tmp.count = 1
			rc = user.u_recharge_countmgr:create(tmp)
			user.u_recharge_countmgr:add(rc)
			rc:update_db(const.DB_PRIORITY_2)
		end
		local count = rc:get_field("count")
		if count > 1 then
			local diamond = user.u_propmgr:get_by_csv_id(const.DIAMOND)
			diamond:set_field("num", ((goods.diamond + goods.gift) * v.num))
			diamond:update_db({"num"})
		elseif count == 1 then
			local diamond = user.u_propmgr:get_by_csv_id(const.DIAMOND)
			diamond:set_field("num", (assert(goods.diamond) + assert(goods.first)) * v.num)
			diamond:update_db({"num"})
		end

		local tmp = {}
		tmp.user_id = user:get_field("csv_id")
		tmp.csv_id  = v.csv_id
		tmp.id      = genpk_2(tmp.user_id, tmp.csv_id)
		tmp.num     = v.num
		tmp.dt      = os.time()
		local rr = user.u_recharge_recordmgr:create(tmp)
		user.u_recharge_recordmgr:add(rr)
		rr:update_db(const.DB_PRIORITY_2)

		-----------------------------
		local key = string.format("%s:%d", "g_config", 1)
		local config = sd.query(key)
		local user_vip_max = config.user_vip_max
		repeat
			if user.uviplevel >= user_vip_max then
				break
			end
			local key = string.format("%s:%d", "g_recharge_vip_reward", user:get_field("uviplevel") + 1)
			local condition = sd.query(key)
			local progress = user:get_field("recharge_diamond") / condition.diamond
			if progress >= 1 then
				user:set_field("uviplevel", condition.vip)
				user:set_field("exp_max", user:get_field("exp_max") + math.floor(user:get_field("exp_max") * (condition.exp_max_up_p)))
				local up = math.floor(user:get_field("gold_max") * condition.gold_max_up_p)
				user:set_field("gold_max", user:get_field("gold_max") + up)
				user:set_field("equipment_enhance_success_rate_up_p", condition.equipment_enhance_success_rate_up_p)
				user:set_field("store_refresh_count_max", condition.store_refresh_count_max)
				local up = math.floor(user:get_field("prop_refresh") * (condition.prop_refresh_reduction_p/100))
				user:set_field("prop_refresh", user:get_field("prop_refresh") - up)
				local up = math.floor(user:get_field("arena_frozen_time") * (condition.arena_frozen_time_reduction_p/100))
				user:set_field("arena_frozen_time", user:get_field("arena_frozen_time") - up)
				user:set_field("gain_exp_up_p", condition.gain_exp_up_p)
				user:set_field("gain_gold_up_p", condition.gain_gold_up_p)
				user:set_field("purchase_hp_count_max", condition.purchase_hp_count_max)
			else
				user:set_field("uvip_progress", math.floor(progress * 100))
				user:update_db({"uvip_progress"}, const.DB_PRIORITY_2)
				break
			end
		until false
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		ret.u = {
			uname     = user.uname,
	    	uviplevel = user.uviplevel,
	    	uexp      = user.u_propmgr:get_by_csv_id(const.EXP).num,
	    	config_sound = (user.config_sound == 1) and true or false,
	    	config_music = (user.config_music == 1) and true or false,
	    	avatar       = user.avatar,
	    	sign         = user.sign,
	    	c_role_id    = user.c_role_id,
	    	gold         = user.u_propmgr:get_by_csv_id(const.GOLD).num,
	    	diamond      = user.u_propmgr:get_by_csv_id(const.DIAMOND).num,
	    	recharge_total = user.recharge_rmb,
	    	recharge_progress = user.uvip_progress,
	    	recharge_diamond = user.recharge_diamond,
	    	love = user.u_propmgr:get_by_csv_id(const.LOVE).num,
	    	level = user.level
		}
		return ret
	else
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function cls:recharge_all(args)
	-- body
	local user = self._env:get_user()
	local game = self._env:get_game()
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	local l = {}
	local r = skynet.call(game, "lua", "query_g_recharge")
	for k,v in pairs(r) do
		table.insert(l, v)
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.l = l
	return ret
end

function cls:recharge_vip_reward_collect(args)
	-- body
	local user = self._env:get_user()
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	if args.vip == 0 then
		ret.errorcode = errorcode[20].code
		ret.msg = errorcode[20].msg
		return ret
	end
	if args.vip ~= user:get_field("uviplevel") then
		ret.errorcode = errorcode[21].code
		ret.msg = errorcode[21].msg
		return ret
	end
	local rc = user.u_recharge_vip_rewardmgr:get_by_vip(self.vip)
	if rc then
		if rc.collected == 1 then
			ret.errorcode = errorcode[22].code
			ret.msg = errorcode[22].msg
			return ret
		else
			local reward = skynet.call(game, "lua", "query_g_recharge_vip_reward", self.vip)
			local t = util.parse_text(reward.rewared, "%d+%*%d+%*?", 2)
			for i,v in ipairs(t) do
				local prop = user.u_propmgr:get_by_csv_id(v[1])
				if prop then
					prop.num = prop.num + assert(v[2])
					prop:update_db({"num"})
				else
					prop = skynet.call(game, "lua", "query_g_prop", v[1])
					prop.user_id = user.csv_id
					prop.num = assert(v[2])
					prop = user.u_propmgr.create(prop)
					user.u_propmgr:add(prop)
					prop:update_db(const.DB_PRIORITY_2)
				end
			end
			rc.collected = 1
			rc:update_db({"collected"})
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			ret.vip = user.uviplevel
			ret.collected = true
			return ret
		end
	else
		local reward = skynet.call(game, "lua", "query_g_recharge_vip_reward", self.vip)
		local t = util.parse_text(reward.rewared, "%d+%*%d+%*?", 2)
		for i,v in ipairs(t) do
			local prop = get_prop(v[1])
			prop.num = prop.num + assert(v[2])
			prop:update_db({"num"})
		end
		local t = {user_id=user.csv_id, vip=self.vip, collected=1, purchased=0}	
		rc = user.u_recharge_vip_rewardmgr.create(t)
		user.u_recharge_vip_rewardmgr:add(rc)
		rc:update_db(const.DB_PRIORITY_2)
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		ret.vip = user.uviplevel
		ret.collected = true
		return ret
	end
end

function cls:recharge_vip_reward_purchase(args)
 	-- body
 	-- 0. success
 	-- 1. offline
 	-- 2. your vip don't
 	-- 3. has purchased
 	local ret = {}
 	if not user then
 		ret.errorcode = errorcode[2].code
 		ret.msg = errorcode[2].msg
 		return ret
 	end
 	assert(self.vip > 0)
 	if self.vip > user.uviplevel then
 		ret.errorcode = errorcode[21].code
 		ret.msg = errorcode[21].msg
 		return ret
 	end
 	local l = {}
 	local rc = user.u_recharge_vip_rewardmgr:get_by_vip(self.vip)
 	if rc then
 		if rc.purchased == 1 then
 			ret.errorcode = errorcode[25].code
 			ret.msg = errorcode[25].msg
 			return ret
 		else
 			local reward = skynet.call(game, "lua", "query_g_recharge_vip_reward", self.vip)
 			local prop = user.u_propmgr:get_by_csv_id(const.DIAMOND)
 			if prop.num < reward.purchasable_diamond then
 				ret.errorcode = errorcode[6].code
 				ret.msg = errorcode[6].msg
 				return ret
 			end
 			prop.num = prop.num - reward.purchasable_diamond
 			prop:update_db({"num"})
 			local r = util.parse_text(reward.purchasable_gift, "%d+%*%d+%*?", 2)
 			for i,v in ipairs(r) do
 				prop = user.u_propmgr:get_by_csv_id(v[1])
 				if prop then
 					prop.num = prop.num + assert(v[2])
 					prop:update_db({"num"})
 					table.insert(l, { csv_id=prop.csv_id, num=prop.num})
 				else
 					prop = skynet.call(game, "lua", "query_g_prop", v[1])
 					prop.user_id = user.csv_id
 					prop.num = assert(v[2])
 					prop = user.u_propmgr.create(prop)
 					user.u_propmgr:add(prop)
 					prop:update_db(const.DB_PRIORITY_2)
 					table.insert(l, { csv_id=prop.csv_id, num=prop.num})
 				end
 			end
 			rc.purchased = 1
 			rc:update_db({"purchased"})
 			ret.errorcode = errorcode[1].code
 			ret.msg = errorcode[1].msg
 			ret.l = l
 			return ret
 		end
 	else
 		local reward = skynet.call(game, "lua", "query_g_recharge_vip_reward", self.vip)
 		local prop = user.u_propmgr:get_by_csv_id(const.DIAMOND)
 		if prop.num < reward.purchasable_diamond then
 			ret.errorcode = errorcode[6].code
 			ret.msg = errorcode[6].msg
 			return ret
 		end
 		prop.num = prop.num - reward.purchasable_diamond
 		prop:update_db({"num"})
 		local r = util.parse_text(reward.purchasable_gift, "%d+%*%d+%*?", 2)
 		for i,v in ipairs(r) do
 			prop = user.u_propmgr:get_by_csv_id(v[1])
 			if prop then
 				prop.num = prop.num + assert(v[2])
 				prop:update_db({"num"})
 				table.insert(l, { csv_id=prop.csv_id, num=prop.num})
 			else
				prop = skynet.call(game, "lua", "query_g_prop", v[1])
				prop.user_id = user.csv_id
				prop.num = assert(v[2])
				prop = user.u_propmgr.create(prop)
				user.u_propmgr:add(prop)
				prop:update_db(const.DB_PRIORITY_2)
				table.insert(l, { csv_id=prop.csv_id, num=prop.num})
 			end
 		end
 		local t = { user_id=user.csv_id, vip=self.vip, collected=0, purchased=1}
 		rc = user.u_recharge_vip_rewardmgr.create(t)
 		user.u_recharge_vip_rewardmgr:add(rc)
 		rc:update_db(const.DB_PRIORITY_2)
 		ret.errorcode = errorcode[1].code
 		ret.msg = errorcode[1].msg
 		ret.l = l
 		return ret
 	end
end

return cls