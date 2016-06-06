package.path = "./../cat/?.lua;../lualib/?.lua;" .. package.path
package.cpath = "./../cat/luaclib/?.so;" .. package.cpath
local skynet = require "skynet"
require "skynet.manager"
require "functions"
rdb = skynet.localname(".rdb")
wdb = skynet.localname(".db")
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local mc = require "multicast"
local dc = require "datacenter"
local util = require "util"
local errorcode = require "errorcode"
local const = require "const"
local tptr = require "tablepointer"
local context = require "agent_context"

local friendrequest = require "friendrequest"
local friendmgr = require "friendmgr"

local M = {}
local new_emailrequest = require "new_emailrequest"
local checkinrequest = require "checkinrequest"
local exercise_request = require "exercise_request"
local cgold_request = require "cgold_request"
local kungfurequest = require "kungfurequest"
local new_drawrequest = require "new_drawrequest"
local lilian_request = require "lilian_request"
local core_fightrequest = require "core_fightrequest"


table.insert(M, checkinrequest )
table.insert(M, exercise_request )
table.insert(M, cgold_request )
table.insert(M, new_emailrequest )
table.insert(M, kungfurequest )
table.insert(M, new_drawrequest )
table.insert(M, lilian_request )
table.insert(M, core_fightrequest)

-- service internal context


local host
local send_request
local gate
local userid, subid
local secret
local db
local game
local user
local stm = require "stm"
local sharemap = require "sharemap"
local sd = require "sharedata"
local env = context.new()


local CMD       = {}
local REQUEST   = {}
local RESPONSE  = {}
local SUBSCRIBE = {}

local func_gs 
local table_gs = {}

local leaderboards_name = skynet.getenv("leaderboards_name")
local lb = skynet.localname(leaderboards_name)

local global_response_session = 1

local function send_package(pack)
	-- body

	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

local function get_journal()
	-- body
	local factory = env:get_myfactory()
	return factory:get_today()
end

local function get_prop(csv_id)
	-- body
	local factory = env:get_myfactory()
	return factory:get_prop(csv_id)
end

local function get_goods(csv_id)
	-- body
	local factory = env:get_myfactory()
	return factory:get_goods(csv_id)
end

local function store_refresh_reset_count()
	-- body
	-- could refresh the cd of the goods.
	local j = get_journal()
	if j.goods_refresh_reset_count ~= 1 then
		local hour = os.date("%H")
		local min = os.date("%M")
		local sec = os.date("%S")
		local goods_refresh_reset_h = skynet.call("SIMPLEDB", "lua", "GET", "goods_refresh_reset_h")
		if tonumber(hour) > goods_refresh_reset_h then
			j.goods_refresh_count = 0
			j.goods_refresh_reset_count = 1
			j:update_db({"goods_refresh_count", "goods_refresh_reset_count"})
		end
	end
end

local function xilian(role, t)
	-- body
	assert(type(t) == "table")
	local ret = {}
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
		local second = skynet.call(game, "lua", "query_g_property_pool_second", 0, property_pool_id)
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
		local second = skynet.call(game, "lua", "query_g_property_pool_second", 0, property_pool_id)
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
		local second = skynet.call(game, "lua", "query_g_property_pool_second", 0, property_pool_id)
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
		local second = skynet.call(game, "lua", "query_g_property_pool_second", 0, property_pool_id)
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
		local second = skynet.call(game, "lua", "query_g_property_pool_second", 0, property_pool_id)
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

function SUBSCRIBE.update_db()
	-- body
	env:flush_db(const.DB_PRIORITY_3)
end

local function subscribe( )
	-- body				
	local c = skynet.call(".channel", "lua", "agent_start")
	local c2 = mc.new { 			
		channel = c,			
		dispatch = function ( channel, source, cmd, tvals, ... )
			-- body 
			local f = SUBSCRIBE[cmd]
			if f ~= nil then
				f(env, tvals, ...)	
			else 				
				for k,v in pairs(M) do
					if v.SUBSCRIBE[cmd] then
						local f = assert(v.SUBSCRIBE[cmd])
						f(_, env, tvals, ...)
						break		
					end 
				end 	
			end 		
		end 			
	} 					
	c2:subscribe() 		
end 					
						
function REQUEST:achievement(ctx)
	-- body				
	local m = ctx:get_module("achievement")
	local ok, result = pcall(m.achievement, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:achievement_reward_collect(ctx)
	-- body
	local m = ctx:get_module("achievement")
	local ok, result = pcall(m.achievement_reward_collect, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end 
	
local function get_public_email(ctx)
	assert(ctx)
	
	local r = skynet.call( ".channel" , "lua" , "agent_get_public_email" , ctx:get_user():get_csv_id() , ctx:get_user():get_pemail_csv_id() , ctx:get_user():get_signup_time() )
	assert( r )
	local pemail_csv_id = ctx:get_user():get_pemail_csv_id()
	local sign = false
	
	if #r >= 1 then
		pemail_csv_id = r[1].pemail_csv_id
		print("user.pemail_csv_id is ", ctx:get_user():get_pemail_csv_id(), r[1].pemail_csv_id)
		sign = true
	end
	
	for k , v in ipairs( r ) do		
		v.pemail_csv_id = nil
		v.id = genpk_2(ctx:get_user():get_csv_id(), v.csv_id)
		new_emailrequest:public_email(ctx:get_myfactory(), v , ctx:get_user() )
	end 

	if sign then
		ctx:get_user():set_pemail_csv_id(pemail_csv_id)
		ctx:get_user():update_db()
	end
end    	
	 	
function REQUEST:role_info()
	local m = ctx:get_module("role")
	local ok, result = pcall(m.role_info, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end	

function REQUEST:choose_role()
	assert(false)
end	
	
function REQUEST:role_upgrade_star()
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
		
function REQUEST:wake()
	assert(false)
end		

function REQUEST:props(ctx)
	-- body
	local m = ctx:get_module("prop")
	local ok, result = pcall(m.props, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:use_prop(ctx)
	-- body
	local m = ctx:get_module("prop")
	local ok, result = pcall(m.use_prop, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:user(ctx)
	-- body
	local ret = {}
	print("called****************************111")
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg	= errorcode[2].msg
		return ret
	end
	local modelmgr = ctx:get_modelmgr()
	local u_propmgr = modelmgr:get_u_propmgr()
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
	ret.user.uviplevel = (1 << 48)
	print("called****************************222")
	ret.user.equipment_list = {}
	for k,v in pairs(user.u_equipmentmgr.__data) do
		table.insert(ret.user.equipment_list, v)
	end
	print("called****************************333")
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

function REQUEST:user_can_modify_name()
	-- body
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

function REQUEST:user_modify_name()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg	= errorcode[2].msg
		return ret
	end
	if user.modify_uname_count >= 1 then
		local prop = user.u_propmgr:get_by_csv_id(const.DIAMOND)
		if prop.num >= 100 then
			prop.num = prop.num - 100
			prop:update_db({"num"})
			user.uname = self.name
			user.modify_uname_count = user.modify_uname_count + 1
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
		user.uname = self.name
		user.modify_uname_count = user.modify_uname_count + 1
		user:update_db({"modify_uname_count", "uname"}, const.DB_PRIORITY_2)
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		return ret
	end
end

function REQUEST:user_upgrade(ctx)
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

function REQUEST:shop_all(ctx)
	-- body
	local m = ctx:get_module("shop")
	local ok, result = pcall(m.shop_all, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:shop_refresh(ctx)
	-- body
	local m = ctx:get_module("shop")
	local ok, result = pcall(m.shop_refresh, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:shop_purchase(ctx)
	-- body
	local m = ctx:get_module("shop")
	local ok, result = pcall(m.shop_purchase, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:recharge_all(ctx)
	-- body
	local m = ctx:get_module("recharge")
	local ok, result = pcall(m.recharge_all, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:recharge_purchase(ctx)
	-- body
	local m = ctx:get_module("recharge")
	local ok, result = pcall(m.recharge_purchase, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:recharge_vip_reward_all(ctx)
	-- body
	local m = ctx:get_module("recharge")
	local ok, result = pcall(m.recharge_vip_reward_all, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:recharge_vip_reward_collect()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	if self.vip == 0 then
		ret.errorcode = errorcode[20].code
		ret.msg = errorcode[20].msg
		return ret
	end
	if self.vip > user.uviplevel then
		ret.errorcode = errorcode[21].code
		ret.msg = errorcode[21].msg
		return ret
	end
	assert(user)
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

function REQUEST:equipment_enhance()
	-- body
	assert(self.csv_id, string.format("from client the value is: %s", type(self.csv_id)))
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	local e = assert(user.u_equipmentmgr:get_by_csv_id(self.csv_id))
	if e.csv_id == 1 then
		local last = user.u_equipmentmgr:get_by_csv_id(4)
		assert(e.level == last.level)
	else
		local last = user.u_equipmentmgr:get_by_csv_id(e.csv_id - 1)
		assert(e.level < last.level)
	end
	local ee = skynet.call(game, "lua", "query_g_equipment_enhance", e.csv_id*1000 + e.level + 1)
	if ee.level > user.level then
		ret.errorcode = errorcode[23].code
		ret.msg = errorcode[23].msg
		return ret
	end
	local currency = user.u_propmgr:get_by_csv_id(ee.currency_type)
	if currency.num < ee.currency_num then
		ret.errorcode = errorcode[6].code
		ret.msg = errorcode[6].msg
		return ret
	else
		assert(currency.num >= ee.currency_num)
		local r = math.random(0, 100)
		if r < e.enhance_success_rate + (e.enhance_success_rate * user.equipment_enhance_success_rate_up_p/100) then
			currency.num = currency.num - ee.currency_num
			assert(currency.num > 0)
			currency:update_db({"num"})
			for k,v in pairs(e) do
				if ee[k] then
					e[k] = ee[kk]
				end
			end	
			ret.errorcode = errorcode[1].code
			ret.msg = errorcode[1].msg
			ret.e = {}
			ret.e.csv_id = assert(e.csv_id)
			ret.e.level = assert(e.level)
			ret.e.combat = assert(e.combat)
			ret.e.defense = assert(e.defense)
			ret.e.critical_hit = assert(e.critical_hit)
			ret.e.king = assert(e.king)
			ret.e.combat_probability = assert(e.combat_probability)
			ret.e.defense_probability = assert(e.defense_probability)
			ret.e.critical_hit_probability = assert(e.critical_hit_probability)
			ret.e.defense_probability = assert(e.defense_probability)
			ret.e.enhance_success_rate = assert(e.enhance_success_rate)
			if e.csv_id == 4 and e.level % 10 == 0 then
				local equip_effect = skynet.call(game, "lua", "query_g_equipment_effect", e.level)
				ret.is_valid = true
				ret.effect = equip_effect.effect
				return ret
			else
				ret.is_valid = false
				ret.effect = 0
				return ret
			end
		else
			ret.errorcode = errorcode[24].code
			ret.msg = errorcode[24].msg
			return ret
		end
	end
end

function REQUEST:equipment_all()
	-- body
	-- 1 offline 
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	local l = {}
	for k,v in pairs(user.u_equipmentmgr.__data) do
		local e = {
			csv_id = assert(v.csv_id),
			level = assert(v.level),
			combat = assert(v.combat),
			defense = assert(v.defense),
			critical_hit = assert(v.critical_hit),
			king = assert(v.king),
			combat_probability = assert(v.combat_probability),
			critical_hit_probability = assert(v.critical_hit_probability),
			defense_probability = assert(v.defense_probability),
			king_probability = assert(v.king_probability),
			enhance_success_rate = assert(v.enhance_success_rate)
		}
		table.insert(l, e)
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.l = l
	return ret
end

function REQUEST:role_all(ctx)
	-- body
	local m = ctx:get_module("role")
	local ok, result = pcall(m.role_all, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:role_recruit(ctx)
	-- body
	local m = ctx:get_module("role")
	local ok, result = pcall(m.role_recruit, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:role_battle(ctx)
	-- body
	local m = ctx:get_module("role")
	local ok, result = pcall(m.role_battle, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:user_sign()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	user.sign = self.sign
	user:update_db({"sign"}, const.DB_PRIORITY_2)
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	return ret
end

function REQUEST:user_random_name()
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

local xilian_lock = 0
local xilian_role_id = 0

function REQUEST:xilian()
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

function REQUEST:checkpoint_chapter(ctx)
	-- body
	local m = ctx:get_module("checkpoint")
	local ok, result = pcall(m.checkpoint_chapter, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:checkpoint_hanging(ctx)
	-- body
	local m = ctx:get_module("checkpoint")
	local ok, result = pcall(m.checkpoint_hanging, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

-- alone 
function REQUEST:checkpoint_hanging_choose(ctx)
	-- body
	local m = ctx:get_module("checkpoint")
	local ok, result = pcall(m.checkpoint_hanging_choose, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:checkpoint_battle_exit(ctx)
	-- body
	local m = ctx:get_module("checkpoint")
	local ok, result = pcall(m.checkpoint_battle_exit, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:checkpoint_battle_enter(ctx)
	-- body
	local m = ctx:get_module("checkpoint")
	local ok, result = pcall(m.checkpoint_battle_enter, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:checkpoint_exit(ctx)
 	-- body
 	local m = ctx:get_module("checkpoint")
	local ok, result = pcall(m.checkpoint_exit, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:checkpoint_drop_collect(ctx, ... )
	-- body
	local m = ctx:get_module("checkpoint")
	local ok, result = pcall(m.checkpoint_drop_collect, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		return ret
	end
end

function REQUEST:ara_enter(ctx, ... )
	-- body
	local m = ctx:get_module("arena")
	local ok, result = pcall(m.ara_enter, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:ara_exit(ctx, ... )
	-- body
	local m = ctx:get_module("arena")
	local ok, result = pcall(m.ara_exit, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:ara_choose_role_enter(ctx, ... )
	-- body
	local m = ctx:get_module("arena")
	local ok, result = pcall(m.ara_choose_role_enter, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:ara_choose_role(ctx, ... )
	-- body
	local m = ctx:get_module("arena")
	local ok, result = pcall(m.ara_choose_role, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:ara_bat_enter(ctx, ... )
 	-- body
end 

function REQUEST:ara_bat_exit(ctx)
	-- body
end

function REQUEST:ara_rfh(ctx)
	-- body
	-- first test when to reset
	local m = ctx:get_module("arena")
	local ok, result = pcall(m.ara_rfh, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:ara_worship(ctx)
	-- body
	local m = ctx:get_module("arena")
	local ok, result = pcall(m.ara_worship, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end	
end

function REQUEST:ara_rnk_reward_collected(ctx)
	-- body
	local m = ctx:get_module("arena")
	local ok, result = pcall(m.ara_rnk_reward_collected, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:ara_convert_pts(ctx, ... )
	-- body
	local m = ctx:get_module("arena")
	local ok, result = pcall(m.ara_convert_pts, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:ara_lp(ctx, ... )
	-- body
	local m = ctx:get_module("arena")
	local ok, result = pcall(m.ara_lp, m, self)
	if ok then
		return result 
	else
		skynet.error(result)
		local ret = {}
		ret.errorcode = errorcode[29].code
		ret.msg = errorcode[29].msg
		return ret
	end
end

function REQUEST:logout(ctx)
	-- body
	local u = ctx:get_user()
	u:set_ifonline(0)
	ctx:logout()
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
	    local ok, result = pcall(f, args, env)
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
    local ok, result = pcall(f, args, env)

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
				end
			else
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
	
function CMD:friend(source, subcmd, ... )
	-- body
	local f = assert(friendrequest[subcmd])
	local r =  f(friendrequest, ...)
	if r then
		return r
	end
end

function CMD:newemail(source, subcmd , ... )
	local f = assert( new_emailrequest[ subcmd ] )
	f( new_emailrequest , ... )
end

function CMD:ara_user(source)
	-- body
	local modelmgr = self:get_modelmgr()
	local r = modelmgr:gen_remote()
	print("###################################################ara_user")
	for k,v in pairs(r) do
		for kk,v in pairs(v) do
			print(kk,vv)
		end
	end
	return r
end

local function enter_ara(u, ... )
	-- body
	local key = string.format("%s:%d", "g_config", 1)
	local r = sd.query(key)
	local ara_clg_tms_rst_tp = r["ara_clg_tms_rst_tm"]
	local ara_clg_tms_rst_tm = u:get_ara_clg_tms_rst_tm()
	local now = os.time()
	local m = now - ara_clg_tms_rst_tm
	if ara_clg_tms_rst_tm == 0 or ara_clg_tms_rst_tm == nil then
		local tmp = os.date("*t", os.time())
		tmp = { year=tmp.year, month=tmp.month, day=tmp.day, hour=ara_clg_tms_rst_tp}
		local sec = os.time(tmp)
		user:set_ara_clg_tms_rst_tm(sec)
	elseif m > 0 then
		m = m // 86400
		if m % 3600 > 0 then
			m = m + 1
		end
		ara_clg_tms_rst_tm = ara_clg_tms_rst_tm + (m * 86400)
		-- u:set_ara_clg_tms_rst_tm(ara_clg_tms_rst_tm)
	end
end

function CMD:signup(source, uid, sid, sct, g, d)
	-- body
	skynet.error(string.format("%s is login", uid))
	gate   = source
	userid = uid
	subid  = sid
	secret = sct
	game   = ".game"
	db     = ".db"

	env:set_gate(source)
	env:set_userid(userid)
	env:set_subid(subid)
	env:set_secret(secret)
	local modelmgr = self:get_modelmgr()
	user = modelmgr:signup(userid)
	
	local onlinetime = os.time()
	user.ifonline = 1
	user.onlinetime = onlinetime
	user.friendmgr = friendmgr:loadfriend( user , dc )
	friendrequest.getvalue(user, send_package, send_request)

	-- online
	for k,v in pairs(M) do
		if v.REQUEST then
			v.REQUEST["login"](v.REQUEST, user)
		end
	end

	dc.set(user.csv_id, "client_fd", client_fd)
	dc.set(user.csv_id, "online", true)
	dc.set(user.csv_id, "addr", skynet.self())
	env:set_user(user)

	self:login(user)

	
	return true
end 

function CMD:login(source, uid, sid, sct, g, d)
	-- body
	skynet.error(string.format("%s is login", uid))
	gate   = source
	userid = uid
	subid  = sid
	secret = sct
	game   = ".game"
	db     = ".db"
	
	env:set_gate(source)
	env:set_userid(userid)
	env:set_subid(subid)
	env:set_secret(secret)

	local modelmgr = env:get_modelmgr()
	user = modelmgr:load(uid)

	local onlinetime = os.time()
	user.ifonline = 1
	user.onlinetime = onlinetime
	user.friendmgr = friendmgr:loadfriend( user , dc )
	friendrequest.getvalue(user, send_package, send_request)

	assert(user, "user must be a certernaly value.")

	for k,v in pairs(M) do
		if v.REQUEST then
			v.REQUEST["login"](v.REQUEST, user)
		end
	end

	dc.set(user.csv_id, "client_fd", client_fd)
	dc.set(user.csv_id, "online", true)
	dc.set(user.csv_id, "addr", skynet.self())

	self:set_user(user)
	self:login(user)
	subscribe()

	get_public_email(self)
	print("#####################################123ab")
	print("************************************8", self:get_userid())

	

	return true
end

function CMD:logout(source)
	-- body
	skynet.error(string.format("%s is logout", self:get_userid()))
	self:logout()
end

function CMD:afk(source)
	-- body
	skynet.error(string.format("AFK"))
end

function CMD:user(source, ... )
	-- body
	local u = self:get_user()
	local r = {}
	r.uname = u:get_uname()
	r.total_combat = 10
	return r
end

local function update_db()
	-- body
	while true do
		env:flush_db(const.DB_PRIORITY_3)
		skynet.sleep(100 * 60) -- 1ti == 0.01s
	end
end

local START_SUBSCRIBE = {}

function START_SUBSCRIBE:finish(source, ...)
	-- body
	self:flush_db(const.DB_PRIORITY_1)
	print(string.format("the node agent %d will be finished. you should clean something.", skynet.self()))
	skynet.send(source, "lua", "exit")
end

local function start_subscribe()
	-- body
	local c = skynet.call(".start_service", "lua", "register")
	local c2 = mc.new {
		channel = c,
		dispatch = function (channel, source, cmd, ...)
			-- body
			local f = START_SUBSCRIBE[cmd]
			if f then
				f(env, source, ...)
			end
		end
	}
	c2:subscribe()
end 
	
local function start()
	-- body
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))

	env:set_host(host)
	env:set_send_request(send_request)
	env:set_game(".game")
end 
	
skynet.start(function()
	skynet.dispatch("lua", function(_, source, command, ...)
		print("agent is called" , command)
		local f = CMD[command]
		local result = f(env, source, ... )
		if result then
			skynet.ret(skynet.pack(result))
		end
	end)
	skynet.fork(update_db)
	start()
	start_subscribe()
end)
