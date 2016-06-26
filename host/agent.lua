package.path = "../host/lualib/?.lua;"..package.path
local skynet = require "skynet"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local mc = require "multicast"
local dc = require "datacenter"
local const = require "const"
local util = require "util"
local context = require "agent_context"

local CMD       = {}
local REQUEST   = {}
local RESPONSE  = {}
local SUBSCRIBE = {}


local function subscribe( )
	-- body
	local c = skynet.call(".channel", "lua", "agent_start", user.csv_id, skynet.self())
	local c2 = mc.new {
		channel = c,
		dispatch = function ( channel, source, cmd, tvals , ... )
			-- body
			if SUBSCRIBE[cmd] then
				local f = assert(SUBSCRIBE[cmd])
				f(SUBSCRIBE, tvals, ...)
			else
				for k,v in pairs(M) do
					if v.SUBSCRIBE[cmd] then
						local f = assert(v.SUBSCRIBE[cmd])
						f(SUBSCRIBE, tvals, ...)
						break		
					end
				end
			end
		end
	}
	c2:subscribe()
end



		prop:__update_db({"num"})
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
			local n, r = xilian(role, {role_id=role.csv_id, is_locked1=false, is_locked2=false, is_locked3=false, is_locked4=false, is_locked5=false})
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
		context:raise_achievement(const.ACHIEVEMENT_T_5)
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

function REQUEST:role_battle()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user.u_rolemgr:get_by_csv_id(self.csv_id))
	user.c_role_id = self.csv_id
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	return ret
end

<<<<<<< HEAD
function REQUEST:user_sign()
=======
function REQUEST:ready(args)
>>>>>>> d51e1233e2de15326de56876479f6008f895ff3d
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	user.sign = self.sign
	user:__update_db({"sign"}, const.DB_PRIORITY_2)
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	return ret
end

<<<<<<< HEAD
function REQUEST:user_random_name()
=======
function REQUEST:mp(args)
>>>>>>> d51e1233e2de15326de56876479f6008f895ff3d
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.name = "lihong"
	return ret
end

function REQUEST:recharge_vip_reward_purchase()
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
 			prop:__update_db({"num"})
 			local r = util.parse_text(reward.purchasable_gift, "%d+%*%d+%*?", 2)
 			for i,v in ipairs(r) do
 				prop = user.u_propmgr:get_by_csv_id(v[1])
 				if prop then
 					prop.num = prop.num + assert(v[2])
 					prop:__update_db({"num"})
 					table.insert(l, { csv_id=prop.csv_id, num=prop.num})
 				else
 					prop = skynet.call(game, "lua", "query_g_prop", v[1])
 					prop.user_id = user.csv_id
 					prop.num = assert(v[2])
 					prop = user.u_propmgr.create(prop)
 					user.u_propmgr:add(prop)
 					prop:__insert_db(const.DB_PRIORITY_2)
 					table.insert(l, { csv_id=prop.csv_id, num=prop.num})
 				end
 			end
 			rc.purchased = 1
 			rc:__update_db({"purchased"})
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
 		prop:__update_db({"num"})
 		local r = util.parse_text(reward.purchasable_gift, "%d+%*%d+%*?", 2)
 		for i,v in ipairs(r) do
 			prop = user.u_propmgr:get_by_csv_id(v[1])
 			if prop then
 				prop.num = prop.num + assert(v[2])
 				prop:__update_db({"num"})
 				table.insert(l, { csv_id=prop.csv_id, num=prop.num})
 			else
				prop = skynet.call(game, "lua", "query_g_prop", v[1])
				prop.user_id = user.csv_id
				prop.num = assert(v[2])
				prop = user.u_propmgr.create(prop)
				user.u_propmgr:add(prop)
				prop:__insert_db(const.DB_PRIORITY_2)
				table.insert(l, { csv_id=prop.csv_id, num=prop.num})
 			end
 		end
 		local t = { user_id=user.csv_id, vip=self.vip, collected=0, purchased=1}
 		rc = user.u_recharge_vip_rewardmgr.create(t)
 		user.u_recharge_vip_rewardmgr:add(rc)
 		rc:__insert_db(const.DB_PRIORITY_2)
 		ret.errorcode = errorcode[1].code
 		ret.msg = errorcode[1].msg
 		ret.l = l
 		return ret
 	end
end

<<<<<<< HEAD
local xilian_lock = 0
local xilian_role_id = 0

function REQUEST:xilian()
=======
function REQUEST:am(args)
>>>>>>> d51e1233e2de15326de56876479f6008f895ff3d
	-- body
	xilian_lock = 0
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
 		ret.msg = errorcode[2].msg
 		return ret
	end
	assert(self)
	xilian_role_id = self.role_id
	local role = user.u_rolemgr:get_by_csv_id(self.role_id)
	local n, r = xilian(role, self)
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
	
	xilian_lock = 1
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

<<<<<<< HEAD
function REQUEST:xilian_ok()
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

function REQUEST:checkpoint_chapter()
=======
function REQUEST:rob(args)
>>>>>>> d51e1233e2de15326de56876479f6008f895ff3d
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].code
	ret.l = {}
	for k,v in pairs(user.u_checkpointmgr.__data) do
		table.insert(ret.l, v)
	end
	return ret
end

<<<<<<< HEAD
local function hanging()
=======
function REQUEST:lead(args)
>>>>>>> d51e1233e2de15326de56876479f6008f895ff3d
	-- body
	local r = skynet.call(game, "lua", "query_g_checkpoint", user.cp_hanging_id)
	assert(r)
	local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(user.cp_hanging_id)
	assert(cp_rc)
	local now = os.time()
	-- cac hanging 
	local walk = now - cp_rc.hanging_starttime + cp_rc.hanging_walk
	cp_rc.hanging_starttime = now
	cp_rc.hanging_walk = (walk % r.cd)
	local n = walk / r.cd
	local l = {}
	local prop = user.u_propmgr:get_by_csv_id(const.GOLD)
	prop.num = math.floor(prop.num + (n * r.gain_gold))
	table.insert(l, prop)
	prop = user.u_propmgr:get_by_csv_id(const.EXP)
	prop.num = math.floor(prop.num + (n * r.gain_exp))
	table.insert(l, prop)
	-- cac drop
	walk = now - cp_rc.hanging_drop_starttime + cp_rc.hanging_drop_walk
	cp_rc.hanging_drop_starttime = now
	cp_rc.hanging_drop_walk = (walk % r.cd)
	n = walk / 100
	prop = user.u_propmgr:get_by_csv_id(r.drop)
	prop.num = prop.num + 1
	table.insert(l, prop)
	return l
end

<<<<<<< HEAD
function REQUEST:checkpoint_hanging()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	-- enter
	if user.cp_hanging_id > 0 then 
		local ok, result = pcall(hanging)
		if ok then
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			ret.props = result
			return ret
		else
			ret.errorcode = errorcode[29].code
			ret.msg = errorcode[29].msg
			return ret
		end
	else
		ret.errorcode = errorcode[34].code
		ret.msg = errorcode[34].msg
		return ret
	end
end

local function choose(csv_id, now)
	-- body
	-- first resolve last hanging
	assert(now)
	local ret = {}
	if user.cp_hanging_id > 0 then
		if user.cp_hanging_id ~= csv_id then
			local ok, result = pcall(hanging)
			if not ok then
				skynet.error(result)
				ret.errorcode = errorcode[29].code
				ret.msg = errorcode[29].msg
				return false, ret
			end
			local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(user.cp_hanging_id)
			cp_rc.hanging_starttime = 0
			cp_rc.hanging_drop_starttime = 0
			user.cp_hanging_id = csv_id
		end
	else
		-- reslove this time hanging
		user.cp_hanging_id = csv_id
		local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(csv_id) 
		cp_rc.hanging_starttime = now
		cp_rc.hanging_drop_starttime = now
	end

	-- in the n
	if user.cp_battle_id > 0 then
		if user.cp_battle_id ~= csv_id then
			local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(user.cp_battle_id)
			if cp_rc.cd_finished == 0 then
				cp_rc.cd_walk = cp_rc.cd_walk + (now - cp_rc.cd_starttime)
				cp_rc.cd_starttime = 0
				local r = skynet.call(game, "lua", "query_g_checkpoint", csv_id)
				if cp_rc.cd_walk >= r.cd then
					cp_rc.cd_finished = 1
				end
			end	
			user.cp_battle_id = 0
			user.cp_battle_chapter = 0
		end
	end
	return true
end

-- alone 
function REQUEST:checkpoint_hanging_choose()
	-- body
	local ret = {}
	assert(user, "user is nil")
	assert(self.chapter*1000+self.type*100+self.checkpoint == self.csv_id)
	-- must <= cp_chapter
	assert(self.chapter <= user.cp_chapter)
	-- judge chapter 
	local now = os.time()
	local cp = user.u_checkpointmgr:get_by_chapter(self.chapter)
	local cp_chapter = skynet.call(game, "lua", "query_g_checkpoint_chapter", self.chapter)
	if self.type == 0 then
		assert(self.checkpoint <= cp_chapter.type0_max)
		assert(self.checkpoint <= cp.chapter_type0)
		local ok, result = choose(self.csv_id, now)
		if not ok then
			return result 
		end
	elseif self.type == 1 then
		assert(self.checkpoint <= cp_chapter.type1_max, string.format("checkpoint:%d from client > cp_chapter.type1_max:%d", self.checkpoint, cp_chapter.type1_max))
		assert(self.checkpoint <= cp.chapter_type1)
		local ok, result = choose(self.csv_id, now)
		if not ok then
			return result 
		end
	elseif self.type == 2 then
		assert(self.checkpoint <= cp_chapter.type2_max, string.format("checkpoint:%d from client > cp_chapter.type1_max:%d", self.checkpoint, cp_chapter.type2_max))
		assert(self.checkpoint <= cp.chapter_type2)
		local ok, result = choose(self.csv_id, now)
		if not ok then
			return result 
		end
	else
		error("wrong checkpoint type")
		ret.errorcode = errorcode[37].code
		ret.msg = errorcode[37].msg
		return ret
=======
local function request(name, args, response)
	local f = REQUEST[name]
	if f then
		local ok, result = pcall(f, env, args)
		if ok then
			return response(result)
		else
			local ret = {}
			ret.errorcode = errorcode[29].code
			ret.msg = errorcode[29].msg
			return response(result)
		end
	else
		local ret = {}
		ret.errorcode = errorcode[39].code
		ret.msg = errorcode[39].msg
		return response(result)
>>>>>>> d51e1233e2de15326de56876479f6008f895ff3d
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	return ret
end

function REQUEST:checkpoint_battle_exit()
	-- body
	local ret = {}
	assert(user ~= nil, "user is nil")
	assert(self.chapter <= user.cp_chapter, string.format("self.chapter:%d > user.cp_chapter:%d", self.chapter, user.cp_chapter))
	assert(self.chapter == user.cp_battle_chapter)
	assert(self.csv_id == user.cp_battle_id, string.format("user.cp_battle_id:%d is ", user.cp_battle_id))
	local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(self.csv_id)
	assert(cp_rc.cd_finished == 1)
	if self.result == 1 then
		local r = skynet.call(game, "lua", "query_g_checkpoint", self.csv_id)
		local cp = user.u_checkpointmgr:get_by_chapter(r.chapter)
		local cp_chapter = skynet.call(game, "lua", "query_g_checkpoint_chapter", r.chapter)
		-- reward
		local reward = {}
		local tmp = util.parse_text(r.reward, "(%d+%*%d+%*?)", 2)
		for i,v in ipairs(reward) do
			local prop = user.u_propmgr:get_by_csv_id(v[1])
			prop.num = prop.num + v[2]
			table.insert(reward, prop)
		end
		-- unlock next checkpoint
		if r.type == 0 then
			assert(cp.chapter_type0 == r.checkpoint)  -- keep progress
			cp.chapter_type0 = cp.chapter_type0 + 1
			if cp.chapter_type0 > cp_chapter.type0_max then
				-- unlock next chapter
				if user.cp_chapter == r.chapter then
					user.cp_chapter = user.cp_chapter + 1
					local cp_chapter_max = skynet.call(game, "lua", "query_g_config", "cp_chapter_max")
					if user.cp_chapter <= cp_chapter_max then   
						local next_cp = user.u_checkpointmgr:get_by_chapter(user.cp_chapter)
						next_cp.chapter_type0 = 1
					end
				end
				-- unlock next type
				if cp.chapter_type1 ~= 0 then
					error("db is wrong")
					ret.errorcode = errorcode[35].code
					ret.msg = errorcode[35].code
					return ret
				else
					cp.chapter_type1 = 1
				end
			end
		elseif r.type == 1 then
			if cp.chapter_type1 ~= r.checkpoint then
				ret.errorcode = errorcode[35].code
				ret.msg = errorcode[35].msg
				return ret
			end
			assert(cp.chapter_type1 == r.checkpoint)
			cp.chapter_type1 = cp.chapter_type1 + 1
			if cp.chapter_type1 > cp_chapter.type1_max then
				-- unlock next type
				if cp.chapter_type2 ~= 0 then
					error("db is wrong.")
					ret.errorcode = errorcode[35].code
					ret.msg = errorcode[35].msg
					return ret
				else
					cp.chapter_type2 = 1
				end
			end
		elseif r.type == 2 then
			if cp.chapter_type2 ~= r.checkpoint then
				ret.errorcode = errorcode[35].code
				ret.msg = errorcode[35].msg
				return ret
			end
			assert(cp.chapter_type2 == r.checkpoint)
			cp.chapter_type2 = cp.chapter_type2 + 1
		end
		user.cp_battle_id = 0
		user.cp_battle_chapter = 0
		skynet.error(string.format("you passed chapter:%d, type:%d, checkpoint:%d", self.chapter, self.type, self.checkpoint))
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		ret.reward = reward
		return ret
	else
		skynet.error("you lose.")
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].code
		return ret
	end
end

function REQUEST:checkpoint_battle_enter()
	-- body
	local ret = {}
	assert(user ~= nil, "user is nil")
	assert(self.chapter <= user.cp_chapter)
	assert(self.csv_id == user.cp_hanging_id, string.format("self.csv_id:%d, user.cp_hanging_id:%d", self.csv_id, user.cp_hanging_id))
	-- check 
	local cp = user.u_checkpointmgr:get_by_chapter(self.chapter)
	if self.type == 0 then
		assert(self.checkpoint == cp.chapter_type0)
	elseif self.type == 1 then
		assert(self.checkpoint == cp.chapter_type1)
	elseif self.type == 2 then
		assert(self.checkpoint == cp.chapter_type2)
	else
		ret.errorcode = errorcode[35].code
		ret.msg = errorcode[35].msg
		return ret
	end
	local now = os.time()
	if user.cp_battle_id == 0 then
		user.cp_battle_id = self.csv_id
		user.cp_battle_chapter = self.chapter
		local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(self.csv_id)
		assert(cp_rc.cd_starttime == 0)
		if cp_rc.cd_finished == 1 then
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			return ret
		else
			cp_rc.cd_starttime = now
			local r = skynet.call(game, "lua", "query_g_checkpoint", self.csv_id)
			if r.cd - cp_rc.cd_walk > 0 then
				ret.errorcode = errorcode[1].code
				ret.msg = errorcode[1].msg
				ret.cd = r.cd - cp_rc.cd_walk
				return ret
			else
				cp_rc.cd_starttime = 0
				cp_rc.cd_finished = 1
				ret.errorcode = errorcode[1].code
				ret.msg = errorcode[1].msg
				ret.cd = 0
				return ret
			end
		end
	else
		assert(user.cp_battle_id == self.csv_id)
		assert(user.cp_battle_chapter == self.chapter)
		local cp_rc = user.u_checkpoint_rcmgr:get_by_csv_id(self.csv_id)
		assert(cp_rc.cd_starttime > 0, string.format("cd_starttime:%d", cp_rc.cd_starttime))
		assert(cp_rc.cd_finished == 0)
		local walk = now - cp_rc.cd_starttime + cp_rc.cd_walk
		cp_rc.cd_walk = walk
		cp_rc.cd_starttime = now
		local r = skynet.call(game, "lua", "query_g_checkpoint", self.csv_id)
		if r.cd - cp_rc.cd_walk > 0 then
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			ret.cd = r.cd - cp_rc.cd_walk
			return ret
		else
			cp_rc.cd_starttime = 0
			cp_rc.cd_finished = 1
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			ret.cd = 0
			return ret
		end
	end
end

function REQUEST:checkpoint_exit()
 	-- body
 	local ret = {}
 	if not user then
 		ret.errorcode = errorcode[2].code
 		ret.msg = errorcode[2].msg
 		return ret
 	end
 	cp_exit()
	ret.errorcode = errorcode[1].code
 	ret.msg = errorcode[1].msg
	return ret
end

function REQUEST:ara_bat_ovr()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	local prop = user.u_propmgr:get_by_csv_id(const.ARA_INTEGRAL)
	if self.win == 1 then
		user.ara_win_tms = user.ara_win_tms + 1
		prop.num = prop.num + 2
	elseif self.win == 0 then
		user.ara_tie_tms = user.ara_tie_tms + 1
		prop.num = prop.num + 2
	elseif self.win == -1 then
		user.ara_lose_tms = user.ara_lose_tms + 1
		prop.num = prop.num + 1
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.ara_points = prop.num
	ret.ara_win_tms = user.ara_win_tms
	ret.ara_lose_tms = user.ara_lose_tms
	local leaderboards_name = skynet.getenv("leaderboards_name")
	local l = skynet.call(leaderboards_name, "lua", "ranking_range", 1, 100)
	ret.ara_leaderboards = l
	ret.rmd_list = 
	return ret
end

function REQUEST:ara_bat_clg()
	-- body
	local t = user.u_journalmgr:get_by_today()
	if t.ara_clg_tms > 0 then
		t.ara_clg_tms = t.ara_clg_tms - 1
		-- TODO: enter ara
	end
end

function REQUEST:ara_rfh()
	-- body
	-- if user.ara_rnk
	skynet.call(lp, "lua", "")
end

function REQUEST:ara_worship()
	-- body
	local ret = {}
	local rand = math.random()
	if rand % 1 == 1 then
		local id = skynet.call(game, "lua", "worship_reward_id")
		local num = skynet.call(game, "lua", "worship_reward_num")
		local prop = user.u_propmgr:get_by_csv_id(id)
		prop.num = prop.num + num
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		return ret
	else
		ret.errorcode = errorcode[33].code
		ret.msg = errorcode[33].msg
		return ret
	end
end

function REQUEST:ara_clg_tms_purchase()
	-- body
	-- u_journalmgr
	skynet.call()
end

function REQUEST:ara_rnk_reward_collected()
	-- body
	local ret = {}
	local rnk = skynet.call(lp, "lua", "ranking", user.csv_id)
	local rnk_rwd = user.u_ara_rnk_rwd:get_by_csv_id(rnk)
	if rnk_rwd == nil or rnk_rwd.is_collected == 0 then
		local r = skynet.call(game, "lua", "query_g_ara_rnk_rwd", rnk)
		r = util.parse_text(r, "(%d+%*%d+%*?)", 2)
		for i,v in ipairs(r) do
			local prop = user.u_propmgr:get_by_csv_id(v[1])
			prop.num = prop.num + v[2]
		end
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		return ret
	else
		ret.errorcode = errorcode[38].code
		ret.msg = errorcode[38].msg
		return ret
	end
end

local function generate_session()
	local session = 0
	return function () 
		session = session + 1
		return session
	end 
end

local function request(name, args, response)
	skynet.error(string.format("line request: %s", name))
    local f = nil
    if REQUEST[name] ~= nil then
    	f = REQUEST[name]
    elseif nil ~= friendrequest[ name ] then
    	f = friendrequest[name]
    else
    	for i,v in ipairs(M) do
    		if v.REQUEST[name] ~= nil then
    			f = v.REQUEST[name]
    			break
    		end
    	end
    end

    if f then
	    local ok, result = pcall(f, args)
	    if ok then
			return response(result)
		else
			skynet.error(result)
			local ret = {}
			ret.errorcode = errorcode[29].code
			ret.msg = errorcode[29].msg
			return response(ret)
		end
	else
		local ret = {}
		ret.errorcode = errorcode[39].code
		ret.msg = errorcode[39].msg
		return response(ret)
	end
end      

function RESPONSE:finish_achi( ... )
	-- body
	assert(self.errorcode == 1)
	skynet.error(self.msg)
end

local function response(session, args)
	-- body
	print( "name and args is*******************************" , session )
	assert( table_gs[tostring(session)], "has not register such session!" )
	local name = table_gs[tostring(session)]
	skynet.error(string.format("response: %s", name))
    local f = nil
    if RESPONSE[name] ~= nil then
    	f = RESPONSE[name]
    elseif nil ~= friendrequest[name] then
    	f = friendrequest[name]
    else
    	for i,v in ipairs(M) do
    		if v.RESPONSE[name] ~= nil then
    			f = v.RESPONSE[name]
    			break
    		end
    	end
    end
    assert(f)
    assert(response)
    local ok, result = pcall(f, args)

    if ok then
    	table_gs[tostring(session)] = nil
    else
    	assert(false, "pcall failed in response!")
    end
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
<<<<<<< HEAD
		if sz > 0 then
			return host:dispatch(msg, sz)
		elseif sz == 0 then
			return "HEARTBEAT"
		else
			error "error"
		end
	end,
	dispatch = function (_, _, t, ...)
		if t == "REQUEST" then
			local ok, result  = pcall(request, ...)
			if ok then
				if result then
					skynet.retpack(result)
=======
		if env.rdtroom then
			return msg, sz
		else
			if sz == 0 then
				return "HEARTBEAT"
			else	
				return host:dispatch(msg, sz)
			end
		end
	end,
	dispatch = function (session, source, type, ...)
		if env.rdtroom then
			skynet.redirect(env.room, skynet.self(), id, session, type, ...)
		else
			if type == "REQUEST" then
				local ok, result  = pcall(request, ...)
				if ok then
					if result then
						skynet.retpack(result)
					end
				else
					skynet.error(result)
>>>>>>> d51e1233e2de15326de56876479f6008f895ff3d
				end
			elseif type == "RESPONSE" then
				pcall(response, ...)
			else
<<<<<<< HEAD
				assert(false, result)
			end
		elseif t == "HEARTBEAT" then
			assert(false)
			-- send_package(send_request "heartbeat")
		elseif t == "RESPONSE" then
			pcall(response, ...)
		end
	end
}	
	
function CMD.friend(source, subcmd, ... )
	-- body
	local f = assert(friendrequest[subcmd])
	local r =  f(friendrequest, ...)
	if r then
		return r
	end
=======
				error "other type is not existence."
			end
		end
	end
}

function CMD:enter_room(source, room)
	-- body
	self.room = room
	self.rdtroom = true
	-- skynet.
	-- for k,v in pairs(t) do
	-- 	assert(room[k] == nil)
	-- 	room[k] = v
	-- 	send_package(send_request(2, { user_id=tonumber(k), name="hello" })) 
	-- end
>>>>>>> d51e1233e2de15326de56876479f6008f895ff3d
end

function CMD.newemail(source, subcmd , ... )
	local f = assert( new_emailrequest[ subcmd ] )
	f( new_emailrequest , ... )
end

function CMD.signup(source, uid, sid, sct, game, db)
	-- body
	skynet.error(string.format("%s is login", uid))
	gate   = source
	userid = uid
	subid  = sid
	secret = sct
	game   = game
	db     = db

	user = signup(uid, xilian)
	if user == nil then
		return false
	end

	return true

end

function CMD.login(source, uid, sid, sct, game, db)
	-- body
	skynet.error(string.format("%s is login", uid))
	gate   = source
	userid = uid
	subid  = sid
	secret = sct
	game   = game
	db     = db
	
	local times = skynet.call(".logintimes", "lua", "login", uid)
	if times == 1 then
		print("************************************123")
		local signup = require "signup"
		
	else
		
=======
function CMD.signup(source, uid, sid, sct, g, d)
end

function CMD.login(source, uid, sid, secret, g, d)
	-- body
	skynet.error(string.format("%s is login", uid))
	gate = source
	uid = uid
	subid = sid
	game = g
	db = d
>>>>>>> d51e1233e2de15326de56876479f6008f895ff3d

		print("************************************456")
		user = loader.load_user(uid)
	end


	for k,v in pairs(M) do
		if v.REQUEST then
			v.REQUEST["login"](v.REQUEST, user)
		end
	end


	local rnk = skynet.call(lb, "lua", "push", user.csv_id, user.csv_id)
	user.ara_rnk = rnk

	dc.set(user.csv_id, { client_fd=client_fd, addr=skynet.self()})	
	context.user = user

	local onlinetime = os.time()
	user.ifonline = 1
	user.onlinetime = onlinetime
	user:__update_db({"ifonline", "onlinetime"}, const.DB_PRIORITY_2)
	user.friendmgr = friendmgr:loadfriend( user , dc )
	friendrequest.getvalue(user, send_package, send_request)
	--load public email from channel public_emailmgr
	get_public_email()

	subscribe()
	skynet.fork(subscribe)

	local ret = {}
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.u = {
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
		cp_chapter = user.cp_chapter,
		lilian_level = user.lilian_level
	}
	ret.u.uexp = assert(user.u_propmgr:get_by_csv_id(const.EXP)).num
	ret.u.gold = assert(user.u_propmgr:get_by_csv_id(const.GOLD)).num
	ret.u.diamond = assert(user.u_propmgr:get_by_csv_id(const.DIAMOND)).num
	ret.u.love = user.u_propmgr:get_by_csv_id(const.LOVE).num
	ret.u.equipment_list = {}
	for k,v in pairs(user.u_equipmentmgr.__data) do
		table.insert(ret.u.equipment_list, v)
	end
	ret.u.kungfu_list = {}
	for k,v in pairs(user.u_kungfumgr.__data) do
		table.insert(ret.u.kungfu_list, v)
	end
	ret.u.rolelist = {}
	for k,v in pairs(user.u_rolemgr.__data) do
		table.insert(ret.u.rolelist, v)
	end
	
	return true, send_request("login", ret)
end

local function logout()
	-- body
	if gate then
		skynet.call(gate, "lua", "logout", userid, subid)
	end
	skynet.exit()
end

function CMD.logout(source)
	-- body
	skynet.error(string.format("%s is logout", userid))
	logout()
end

function CMD.afk(source)
	-- body
	skynet.error(string.format("AFK"))
end

local function update_db()
	-- body
	while true do
		flush_db(const.DB_PRIORITY_3)
		skynet.sleep(100 * 60) -- 1ti == 0.01s
	end
end

local function start()
	-- body
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))
	
	context.host = host
	context.send_request = send_request
	context.game = game


	local t = loader.load_game()
	for i,v in ipairs(M) do
		v.start(fd, send_request, t)
	end	
end

skynet.start(function()
	skynet.dispatch("lua", function(_, source, command, ...)
		print("agent is called" , command)
		local f = CMD[command]
		local result = f(source, ... )
		if result then
			skynet.ret(skynet.pack(result))
		end
	end)
	skynet.fork(update_db)
	start()
end)
