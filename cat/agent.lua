package.path = "./../cat/?.lua;" .. package.path
local skynet = require "skynet"
require "skynet.manager"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local mc = require "multicast"
local dc = require "datacenter"
local util = require "util"
local loader = require "loader"
local errorcode = require "errorcode"

local friendrequest = require "friendrequest"
local friendmgr = require "friendmgr"
local drawrequest = require "drawrequest"
local drawmgr = require "drawmgr"
local csvReader = require "csvReader"
local const = require "const"
local config = require "config"

local M = {}
local new_emailrequest = require "new_emailrequest"
local checkinrequest = require "checkinrequest"
local exercise_request = require "exercise_request"
local cgold_request = require "cgold_request"
local kungfurequest = require "kungfurequest"
local new_drawrequest = require "new_drawrequest"

table.insert( M , checkinrequest )
table.insert( M , exercise_request )
table.insert( M , cgold_request )
table.insert( M , new_emailrequest )
table.insert( M , kungfurequest )
table.insert( M , new_drawrequest )

local WATCHDOG
local host
local send_request
      
local CMD = {}
local REQUEST = {}
local RESPONSE = {}
local SUBSCRIBE = {}
local client_fd

local game
local user
	  
local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

local function push_achievement(achievement)
	-- body
	ret = {}
	ret.which = {
		csv_id = achievement.csv_id,
		finished = achievement.finished
	}
	send_package(send_request("finish_achi", ret))
end

local function raise_achievement(type, user, game)
	-- body
	if type == "combat" then
	elseif type == const.A_T_GOLD then -- 2
		repeat
			local a = user.u_achievementmgr:get_by_type(const.A_T_GOLD)
			if not a then
				a = game.g_achievementmgr:get_by_csv_id(1001)
				a.user_id = user.csv_id
				a.finished = 0
				a.is_unlock = 1
				a.is_valid = 1
				a = user.u_achievementmgr.create(a)
				user.u_achievementmgr:add(a)
				a:__insert_db()
			end
			if a.is_valid == 0 then
				break
			end
			local gold = user.u_propmgr:get_by_csv_id(const.GOLD) -- abain prop by type (type -- csv_id -- prop.id)		
			local progress = gold.num / a.c_num
			if progress >= 1 then -- success
				a.finished = 100
				a.reward_collected = 0			
				-- insert achievement rc	
				local rc = user.u_achievement_rcmgr.create(a)
				user.u_achievement_rcmgr:add(rc)
				rc:__insert_db()

				if string.match(a.unlock_next_csv_id, "%d*%*%d*") then
					local k1 = string.gsub(a.unlock_next_csv_id, "(%d*)%*(%d*)", "%1")
					local k2 = string.gsub(a.unlock_next_csv_id, "(%d*)%*(%d*)", "%2")
					
					local a1 = game.g_achievementmgr:get_by_csv_id(k1)
					a1.user_id = user.csv_id
					a1.finished = 100
					a1.is_unlock = 1
					a1.reward_collected = 0
					a1 = user.u_achievement_rcmgr.create(a1)
					user.u_achievement_rcmgr:add(a1)
					a1:__insert_db()

					if tonumber(k2) == 0 then
						a.is_valid = 0
						a:__update_db({"is_valid"})	
						break
					else
						local ga = assert(game.g_achievementmgr:get_by_csv_id(k2))
						a.csv_id = ga.csv_id
						a.finished = 0
						a.c_num = ga.c_num
						a.unlock_next_csv_id = ga.unlock_next_csv_id
						-- a.is_unlock = 1
						a:__update_db({"csv_id", "finished", "c_num", "unlock_next_csv_id", "is_valid"})	
					end
				else
					local ga = assert(game.g_achievementmgr:get_by_csv_id(a.unlock_next_csv_id))
					a.csv_id = ga.csv_id
					a.finished = 0
					a.c_num = ga.c_num
					a.unlock_next_csv_id = ga.unlock_next_csv_id
					a.is_unlock = 1
					a:__update_db({"csv_id", "finished", "c_num", "unlock_next_csv_id", "is_unlock"})	
				end
			else
				a.finished = progress * 100
				a.finished = math.floor(a.finished)
				a:__update_db({"finished"})
				break
			end
		until false
	elseif type == const.A_T_EXP then
		repeat
			local a = assert(user.u_achievementmgr:get_by_type(type))
			if not a then
				a = game.g_achievementmgr:get_by_csv_id(2001)
				a.user_id = user.csv_id
				a.finished = 0
				a.is_unlock = 1
				a.is_valid = 1
				a = user.u_achievementmgr.create(a)
				user.u_achievementmgr:add(a)
				a:__insert_db()
			end
			if a.is_valid == 0 then
				break
			end
			local prop = user.u_propmgr:get_by_csv_id(const.EXP) -- abain prop by type (type -- csv_id -- prop.id)		
			local progress = prop.num / a.c_num
			if progress >= 1 then -- success
				a.finished = 100
				a.reward_collected = 0
				push_achievement(a)
				
				-- insert achievement rc	
				local rc = user.u_achievement_rcmgr.create(a)
				user.u_achievement_rcmgr:add(rc)
				rc:__insert_db()

				if string.match(a.unlock_next_csv_id, "%d*%*%d*") then
					local k1 = string.gsub(a.unlock_next_csv_id, "(%d*)%*(%d*)", "%1")
					local k2 = string.gsub(a.unlock_next_csv_id, "(%d*)%*(%d*)", "%2")
					
					local a1 = game.g_achievementmgr:get_by_csv_id(k1)
					a1.user_id = user.csv_id
					a1.finished = 100
					a1.is_unlock = 1
					a1.reward_collected = 0
					a1 = user.u_achievement_rcmgr.create(a1)
					user.u_achievement_rcmgr:add(a1)
					a1:__insert_db()

					if tonumber(k2) == 0 then
						a.is_valid = 0
						a:__update_db({"is_valid"})	
						break
					else
						local ga = assert(game.g_achievementmgr:get_by_csv_id(k2))
						a.csv_id = ga.csv_id
						a.finished = 0
						a.c_num = ga.c_num
						a.unlock_next_csv_id = ga.unlock_next_csv_id
						-- a.is_unlock = 1
						a:__update_db({"csv_id", "finished", "c_num", "unlock_next_csv_id", "is_valid"})	
					end

				else
					local ga = assert(game.g_achievementmgr:get_by_csv_id(a.unlock_next_csv_id))
					a.csv_id = ga.csv_id
					a.finished = 0
					a.c_num = ga.c_num
					a.unlock_next_csv_id = ga.unlock_next_csv_id
					a.is_unlock = 1
					a:__update_db({"csv_id", "finished", "c_num", "unlock_next_csv_id", "is_unlock"})	
				end
			else
				a.finished = progress * 100
				a.finished = math.floor(a.finished)
				a:__update_db({"finished"})
				break
			end
		until false
	elseif type == "level" then
	end
end

--[[function SUBSCRIBE:email( tvals, ... )
	-- body
	local v = emailbox:recvemail( tvals )
	local ret = {}
	ret.mail = {}
	local tmp = {}
   	tmp.attachs = {}

    tmp.emailid = v.id
    tmp.type = v.type
    tmp.acctime = os.date("%Y-%m-%d-%H-%M-%s" , v.acctime)
    tmp.isread = v.isread
    tmp.isreward = v.isreward
    tmp.title = v.title
    tmp.content = v.content
	tmp.attachs = v:getallitem()
	tmp.iconid = v.iconid
	ret.mail = tmp
	send_package( send_request( "newemail" ,  ret ) )
end--]]

local function subscribe( )
	-- body
	local c = skynet.call(".channel", "lua", "agent_start", user.csv_id, skynet.self())
	local c2 = mc.new {
		channel = c,
		dispatch = function ( channel, source, cmd, tvals , ... )
			-- body
			print( "************************ commond is " , cmd )
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

function REQUEST:achievement()
	-- body
	-- 1 not online
	-- 2
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "not online"
		return ret
	end
	assert(user)
	local function decorate(v, a)
		-- body
		local cur = user.u_achievementmgr:get_by_type(v.type)
		if cur then
			if cur.is_valid == 1 then
				if cur.csv_id > v.csv_id then
					local r = assert(user.u_achievement_rcmgr:get_by_csv_id(v.csv_id))
					a.finished = r.finished
					a.reward_collected = (r.reward_collected == 1) and true or false
					a.is_unlock = true
				elseif cur.csv_id == v.csv_id then
					a.finished = cur.finished
					a.reward_collected = false
					a.is_unlock = true
				else
					assert(cur.csv_id < v.csv_id)
					a.finished = 0
					a.reward_collected = false
					a.is_unlock = false
				end
			elseif cur.is_valid == 0 then
				local r = assert(user.u_achievement_rcmgr:get_by_csv_id(v.csv_id))
				a.finished = r.finished
				a.reward_collected = (r.reward_collected == 1) and true or false
				a.is_unlock = true
			else
				assert(false)
			end
		else
			if v.is_init == 1 then
				v.user_id = user.csv_id
				v.finished = 0         -- [0, 100]
				v.reward_collected = 0
				v.is_unlock = 1
				v.is_valid = 1
				local achievement = user.u_achievementmgr.create(v)
				user.u_achievementmgr:add(achievement)
				achievement:__insert_db()
				a.finished = v.finished
				a.reward_collected = (v.reward_collected == 1) and true or false
				a.is_unlock = (v.is_unlock == 1) and true or false
			else
			end
		end
		return a
	end
	local l = {}
	for k,v in pairs(game.g_achievementmgr.__data) do
		local a = {}
		a.csv_id = v.csv_id
		decorate(v, a)
		table.insert(l, a)
	end
	ret.errorcode = 0
    ret.msg = "this is all achievement."
    ret.achis = l
    return ret
end

function REQUEST:achievement_reward_collect()
	-- body
	-- 0. success
	-- 1. offline
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "not online"
		return ret
	end
	assert(user)
	assert(self.csv_id)
	local a = user.u_achievement_rcmgr:get_by_csv_id(self.csv_id)
	if a and a.finished == 100 and a.reward_collected == 0 then
		a.reward_collected = 1
		a:__update_db({"reward_collected"})
		local a_src = game.g_achievementmgr:get_by_csv_id(a.csv_id)
		assert(a_src)
		if a_src.type == 2 then
			local csv_id1 = string.gsub(a_src.reward, "(%d*)%*(%d*)", "%1")
			local num1 = string.gsub(a_src.reward, "(%d*)%*(%d*)", "%2")
			local prop = user.u_propmgr:get_by_csv_id(csv_id1)
			if prop then
				prop.num = prop.num + num1
				prop:__update_db({"num"})
			else
				prop = game.g_propmgr:get_by_csv_id(csv_id1)
				prop.user_id = user.csv_id
				prop.num = num1
				prop = user.u_propmgr.create(prop)
				prop:__insert_db()
			end
		end
		ret.errorcode = 0
		ret.msg = "yes"
		return ret
	end
	ret.errorcode = 2
	ret.msg = "no"
	return ret
end
    
function REQUEST:signup()
	-- body
	-- 0. success
	-- 1. account > 8
	-- 2. account already exists.
	local ret = {}
	if #self.account == 0 or #self.password == 0 then
		ret.errorcode = 1
		ret.msg = "length of account must be."
		return ret
	end
	local condition = {{ uaccount = self.account}}
	local addr = util.random_db()
	local r = skynet.call(addr, "lua", "command", "select", "users", condition)
	if #r == 0 then
		local level = game.g_user_levelmgr:get_by_level(1)
		local vip = game.g_recharge_vip_rewardmgr:get_by_vip(0)
		local t = { csv_id=util.guid(game, const.UENTROPY), 
				uname="nihao",
				uaccount=assert(self.account), 
				upassword=assert(self.password), 
				uviplevel=0,
				config_sound=1, 
				config_music=1, 
				avatar=0, 
				sign="peferct ", 
				c_role_id=1, 
				ifonline=0, 
				level=level.level, 
				combat=level.combat, 
				defense=level.defense, 
				critical_hit=level.critical_hit, 
				blessing=0, 
				modify_uname_count=0, 
				onlinetime=0, 
				iconid=0, 
				is_valid=1, 
				recharge_rmb=0, 
				goods_refresh_count=0, 
				recharge_diamond=0, 
				uvip_progress=0, 
				checkin_num=0, 
				checkin_reward_num=0, 
				exercise_level=0, 
				cgold_level=0,
				gold_max=level.gold_max + math.floor(level.gold_max * vip.gold_max_up_p/100),
				exp_max=level.exp_max + math.floor(level.exp_max * vip.exp_max_up_p/100),
				equipment_enhance_success_rate_up_p=assert(vip.equipment_enhance_success_rate_up_p),
				store_refresh_count_max=assert(vip.store_refresh_count_max),
				prop_refresh=0,
				arena_frozen_time=0,
				purchase_hp_count=0, 
				gain_gold_up_p=0,
				gain_exp_up_p=0,
				purchase_hp_count_max=assert(vip.purchase_hp_count_max),
				SCHOOL_reset_count_max=assert(vip.SCHOOL_reset_count_max),
				SCHOOL_reset_count=0 }
		local usersmgr = require "models/usersmgr"
		local u = usersmgr.create(t)
		u:__insert_db()

		local u_equipmentmgr = require "models/u_equipmentmgr"
		local l = {}
		for k,v in pairs(game.g_equipmentmgr.__data) do
			local equip = game.g_equipment_enhancemgr:get_by_csv_id(v.csv_id*1000+v.level)	
			equip.user_id = u.csv_id
			local equip = u_equipmentmgr.create(equip)
			table.insert(l, equip)
		end
		u_equipmentmgr.insert_db(l)

		l = {}
		local u_propmgr = require "models/u_propmgr"
		local prop = game.g_propmgr:get_by_csv_id(const.GOLD)
		prop.user_id = u.csv_id
		prop.num = 100
		prop = u_propmgr.create(prop)
		table.insert(l, prop)

		prop = game.g_propmgr:get_by_csv_id(const.DIAMOND)
		prop.user_id = u.csv_id
		prop.num = 100
		prop = u_propmgr.create(prop)
		table.insert(l, prop)

		prop = game.g_propmgr:get_by_csv_id(const.EXP)
		prop.user_id = u.csv_id
		prop.num = 100
		prop = u_propmgr.create(prop)
		table.insert(l, prop)

		prop = game.g_propmgr:get_by_csv_id(const.LOVE)
		prop.user_id = u.csv_id
		prop.num = 100     
		prop = u_propmgr.create(prop)
		table.insert(l, prop)
		u_propmgr.insert_db(l)

		local newemail = { 
						   type = 2 , title = "new user email" , 
						   content = "Welcome to the game" , 
						   itemsn1 = 1 , itemnum1 = 10000 , 
						   itemsn2 = 2 , itemnum2 = 10000 , 
						   itemsn3 = 3 , itemnum3 = 10000 , 
						   iconid = 10001 
						}  
		skynet.send(".channel", "lua", "send_email_to_group" , newemail ,  { { csv_id = u.csv_id } } )
		-- local u_kungfumgr = require "models/u_kungfumgr"
		-- local kungfu = game.g_kungfumgr:get_by_csv_id(1001)
		-- kungfu.user_id = assert(u.csv_id)
		-- kungfu.is_learned = 0
		-- local k = u_kungfumgr.create(kungfu)
		-- k:__insert_db() 
						   	
		local u_rolemgr = require "models/u_rolemgr"
		local role = game.g_rolemgr:get_by_csv_id(1)
		assert(role)
		local role_star = game.g_role_starmgr:get_by_csv_id(assert(role.csv_id)*1000+assert(role.star))
		for k,v in pairs(role_star) do
			role[k] = v
		end
		role.user_id = assert(u.csv_id)
		role.k_csv_id1 = 0
		role.k_csv_id2 = 0
		role.k_csv_id3 = 0
		role.k_csv_id4 = 0
		role.k_csv_id5 = 0
		role.k_csv_id6 = 0
		role.k_csv_id7 = 0
		role = u_rolemgr.create(role)
		role:__insert_db()

		ret.errorcode = 0
		ret.msg	= "yes"
		return ret
	else
		ret.errorcode = 2
		ret.msg = "account already exists."
		return ret
	end
end 
    
function REQUEST:login()
	-- 0. success
	-- 1. offline.
	-- 2. account already exists
	-- 3. account already login
	local ret = {}
	if user then
		ret.errorcode = 1
		ret.msg	= "account already login"
		return ret
	end
	assert(self.account and	self.password)
	assert(#self.password > 1)
	local condition = {{ uaccount = self.account, upassword = self.password }}
	local addr = util.random_db()
	local r = skynet.call(addr, "lua", "command", "select", "users", condition)
	if #r == 0  then
		ret.errorcode = 2 
		ret.msg = "account no exists"
		return ret
	elseif #r == 1 then
		local usersmgr = require "models/usersmgr"
		user = usersmgr.create(r[1])
		if dc.get(user.csv_id) then
			user = nil
			ret.errorcode = 3
			ret.msg = "account already login"
			return ret
		end

		loader.load_user(user)
		subscribe()
		skynet.fork(subscribe)

		ret.errorcode = 0
		ret.msg = "success"
		ret.u = {
			uname = user.uname,
			uviplevel = user.uviplevel,
			config_sound = (user.config_sound == 1) and true or false,
			config_music = (user.config_music == 1) and true or false,
			avatar = user.avatar,
			sign = user.sign,
			c_role_id = user.c_role_id,
			recharge_total = user.recharge_rmb,
    		recharge_diamond = user.recharge_diamond,
    		recharge_progress = user.uvip_progress
		}
		ret.u.uexp = assert(user.u_propmgr:get_by_csv_id(const.EXP)).num
		ret.u.gold = assert(user.u_propmgr:get_by_csv_id(const.GOLD)).num
		ret.u.diamond = assert(user.u_propmgr:get_by_csv_id(const.DIAMOND)).num
		-- all roles
		local l = {}
		for k,v in pairs(user.u_rolemgr.__data) do
			local prop = user.u_propmgr:get_by_csv_id(v.us_prop_csv_id)
			local r = {
				csv_id = v.csv_id,
				is_possessed = true,
				star = v.star,
				u_us_prop_num = prop and prop.num or 0
			}
			table.insert(l, r)
		end
		ret.rolelist = l
	end 
	dc.set(user.csv_id, { client_fd=client_fd, addr=skynet.self()})
	local onlinetime = os.time()
	user.ifonline = 1
	user.onlinetime = onlinetime
	user:__update_db({"ifonline", "onlinetime"})

	--user.emailbox = emailbox:loademails( user.csv_id )
	--emailrequest.getvalue( user )
	user.friendmgr = friendmgr:loadfriend( user , dc )
	friendrequest.getvalue( user , send_package , send_request )
	--user.drawmgr = drawmgr
	--drawrequest.getvalue( user , game )
	--user.friendmgr:noticeonline( dc )
	return ret
end	

function REQUEST:logout()
	-- body
	-- 0. success
	-- 1. offline
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "offline"
		return ret
	end
	assert(user)
	user.ifonline = 0
	user:__update_db({"ifonline"})
	dc.set( user.csv_id , nil )
	user = nil
	ret.errorcode = 0
	ret.msg = "success"
	return ret
end

function REQUEST:role_info()
	-- 0. success
	-- 1. offline
	-- 2. not enough
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "offline"
		return ret
	end
	assert(user)
	assert(self.role_id)
	local role = assert(user.u_rolemgr:get_by_csv_id(self.role_id))
	ret.errorcode = 0
	ret.msg = "success"
	local num = user.u_propmgr:get_by_csv_id(role.us_prop_csv_id).num
	ret.r = {
		csv_id = role.csv_id,
		is_possessed = true,
		star = role.star,
		u_us_prop_num = num and num or 0
	}
	return ret
end	

function REQUEST:choose_role()
	assert(false)
	assert(user)
	local ret = {}
	if user.c_role_id == self.role_id then
		ret.errorcode = 1
		ret.msg	= "no"
		return ret
	else
		user.c_role_id = self.role_id
		ret.errorcode = 0
		ret.msg = "yes"
		local role = assert(user.u_rolemgr:get_by_csv_id(user.c_role_id))
		ret.r = role:__serialize()
		return ret
	end
end	
	
function REQUEST:role_upgrade_star()
	-- 0. success
	-- 1. offline
	-- 2. not enough
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "offline"
		return ret
	end
	assert(self.role_csv_id)
	local role = assert(user.u_rolemgr:get_by_csv_id(self.role_csv_id))
	local prop = user.u_propmgr:get_by_csv_id(role.us_prop_csv_id)
	local role_star = game.g_role_starmgr:get_by_csv_id(role.csv_id*1000+role.star+1)
	if prop and prop.num >= role_star.us_prop_num then
		prop.num = prop.num - role_star.us_prop_num
		prop:__update_db({"num"})
		role.star = role.star + 1
		role:__update_db({"star"})
		-- return
		ret.errorcode = 0
		ret.msg = "success"
		ret.r = {
			csv_id = role.csv_id,
			is_possessed = true,
			star = role.star,
    		u_us_prop_num = prop.num
		}
		return ret
	else
		ret.errorcode = 2
		ret.msg = "not enough"
		return ret
	end
end		
		
function REQUEST:wake()
	assert(false)
	assert(user)
	assert(self.role_id)
	local ret = {}
	local role = user.u_rolemgr:get_by_csv_id(self.role_id)
	local nowid = id(role.wake_level, role.level)
	for k,v in pairs(wakecost) do
		print(k,v)
	end
	local cost = assert(wakecost[tostring(role.wake_level)])
	for k,v in pairs(cost) do
		for k,v in pairs(cost) do
			print(k,v)
		end
	end
	if role.level > tonumber(cost.level) and user.gold > tonumber(cost.gold) then
		role.wake_level = role.wake_level + 1
		role.level = role.level - 1
		user.gold = user.gold - cost.gold
		ret.errorcode = 0
		ret.msg = "yes"
		ret.r = role
		return ret
	else
		ret.errorcode = 1
		ret.msg	= "level is not enough."
		return ret
	end
end		

function REQUEST:props()
	-- body
	assert(user)
	ret = {}
	local l = {}
	assert(user.u_propmgr.__data)
	local idx = 1
	for k,v in pairs(user.u_propmgr.__data) do
		local p = {}
		p.csv_id = v.csv_id
		p.num = v.num
		l[idx] = p
		idx = idx + 1
	end
	ret.l = l
	return ret	
end

function REQUEST:use_prop()
	-- body
	-- 1 offline
	-- 2 not enough
	-- 3 no exit 0 make use
	local ret = {}
	if not user then
		ret.errorcode = errorcode.OFFLINE.errorcode
		ret.msg = errorcode.OFFLINE.msg
		return ret
	end
	assert(user)
	assert(#self.props >= 1)
	local l = {}
	for k,v in pairs(self.props) do
		local prop = user.u_propmgr:get_by_csv_id(v.csv_id)
		if v.num > 0 then
			-- get
			prop.num = prop.num + v.num
			prop.__update_db({"num"})
			table.insert(l, prop)
		elseif v.num < 0 then
			-- consume
			if prop.num < math.abs(v.num) then
				ret.errorcode = errorcode.NOT_ENOUGH.errorcode
				ret.msg = errorcode.NOT_ENOUGH.msg
				return ret
			end
			prop.num = prop.num + v.num
			prop:__update_db({"num"})
			table.insert(l, prop)

			if assert(prop.use_type) == 0 then
				assert(false)
			elseif assert(prop.use_type) == 1 then -- exp 
				local e = user.u_propmgr:get_by_csv_id(const.EXP)
				e.num = e.num + tonumber(prop.pram1)
				e:__update_db({"num"})
				table.insert(l, prop)
				raise_achievement(const.A_T_EXP, user, game)
			elseif assert(prop.use_type) == 2 then -- gold
				local g = user.u_propmgr:get_by_csv_id(const.GOLD)
				g.num = g.num + tonumber(prop.pram1)
				g:__update_db({"num"})
				table.insert(l, prop)
				raise_achievement(const.A_T_GOLD, user, game)
			elseif assert(prop.use_type) == 3 then
				local r = util.parse_text(prop.pram1, "(%d+%*%d+%*?)", 2)
				for k,v in pairs(r) do
					if v[1] == const.GOLD then
						local prop = user.u_propmgr:get_by_csv_id(const.GOLD)
						prop.num = prop.num + v[2]
						prop:__update_db({"num"})
						raise_achievement(const.A_T_GOLD, user, game)
					elseif v[1] == const.EXP then
						local prop = user.u_propmgr:get_by_csv_id(v[1])
						prop.num = prop.num + v[2]
						prop:__update_db({"num"})
						raise_achievement(const.A_T_EXP, user, game)
					else
						assert(false)
					end
				end
			elseif assert(prop.use_type) == 4 then
				local r = util.parse_text(prop.pram1, "(%d+%*%d+%*%d+%*?)", 3)
				local total = 0
				for i,v in ipairs(r) do
					v.min = total
					total = total + assert(v[3])
					v.max = total
				end
				local rand = math.random(1, total)
				for i,v in ipairs(r) do
					if rand > v.min and rand < v.max then
						local prop = user.u_propmgr:get_by_csv_id(assert(v[1]))
						if prop then
							prop.num = prop.num + assert(v[2])
							prop:__update_db({"num"})
							table.insert(l, prop)
							break
						else
							local t = game.g_propmgr:get_by_csv_id(assert(v[1]))
							t.user_id = user.csv_id
							t.num = assert(v[2])
							prop = user.u_propmgr.create(t)
							user.u_propmgr:add(prop)
							prop:__insert_db()
							table.insert(l, prop)
							break
						end
					else
						-- assert(false)
					end
				end
			end	
		else
			assert(false)
		end
	end
	ret.errorcode = 0
	ret.msg	= "success"
	ret.props = {}
	for i,v in ipairs(l) do
		table.insert(ret.props, { csv_id=v.csv_id, num=v.num})
	end
	return ret
end

function REQUEST:user()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg	= "no online"
		return ret
	end
	assert(user)
	ret.errorcode = 0
	ret.msg = "yes"
	ret.user = {
		uname = user.uname,
    	uviplevel = user.uviplevel,
    	uexp = user.uexp,
    	config_sound = user.config_sound and true or false,
    	config_music = user.config_music and true or false,
    	avatar = user.avatar,
    	sign = user.sign,
    	c_role_id = user.c_role_id,
    	recharge_total = user.recharge_rmb,
    	recharge_diamond = user.recharge_diamond,
    	recharge_progress = user.uvip_progress
	}
	ret.user.uexp = assert(user.u_propmgr:get_by_csv_id(const.EXP)).num
	ret.user.gold = assert(user.u_propmgr:get_by_csv_id(const.GOLD)).num
	ret.user.diamond = assert(user.u_propmgr:get_by_csv_id(const.DIAMOND)).num
	return ret
end

function REQUEST:user_can_modify_name()
	-- body
	local ret = {}
	if user.modify_uname_count >= 1 then
		ret.errorcode = 1
		ret.msg = "no"
	else
		ret.errorcode = 0
		ret.msg = "yes"
	end
	return ret
end

function REQUEST:user_modify_name()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg	= "please login."
		return ret
	end
	if user.modify_uname_count >= 1 then
		ret.errorcode = 2
		ret.msg = "you only have a time to change your name, or you can take money."
		return ret
	end
	user.uname = self.name
	user.modify_uname_count = user.modify_uname_count + 1
	user:__update_db({"modify_uname_count", "uname"})
	ret.errorcode = 0
	ret.msg = "yes"
	return ret
end

function REQUEST:user_upgrade()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode.OFFLINE.errorcode
		ret.msg = errorcode.OFFLINE.msg
		return ret
	end
	assert(user)
	assert(game.g_user_levelmgr)
	local L = game.g_user_levelmgr:get_by_level(user.level + 1)
	local prop = user.u_propmgr:get_by_csv_id(const.EXP)
	if prop.num > tonumber(L.exp) then
		prop.num = prop.num - L.exp
		prop:__update_db({"num"})
		user.level = L.level
		user.combat = L.combat
		user.defense = L.defense
		user.critical_hit = L.critical_hit
		user.gold_max = assert(L.gold_max)
		user.exp_max = assert(L.exp_max)
		user:__update_db({ "level", "combat", "defense", "critical_hit", "gold_max", "exp_max"})
		ret.errorcode = errorcode.SUCCESS.errorcode
		ret.msg = errorcode.SUCCESS.msg
		return ret
	else
		ret.errorcode = 1
		ret.msg	= "not enough exp"
		return ret
	end
end

function REQUEST:shop_all()
	-- body
	-- 0. success
	-- 1. offline
	-- 2. 
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg	= "not online."
		return ret
	end
	assert(user)
	local ll = {}
	for k,v in pairs(game.g_goodsmgr.__data) do
		if v.inventory == 0 then
			local now = os.time()
			if os.difftime(now, v.st) > v.cd then
				v.inventory = v.inventory_init
				v:__update_db({"inventory"})
			else
				v.countdown = now - v.st
				v:__update_db({"countdown"})
			end
		end
		table.insert(ll, v)
	end
	ret.errorcode = 0
	ret.msg = "success"
	ret.l = ll
	local t = os.date("*t", os.time())
	t = { year=t.year, month=t.month, day=t.day}
	local sec = os.time(t)
	local j = user.u_journalmgr:get_by_date(sec)
	if j then
		ret.goods_refresh_count = j.goods_refresh_count
	else
		ret.goods_refresh_count = 0
	end
	ret.store_refresh_count_max = assert(user.store_refresh_count_max)
	return ret
end

function REQUEST:shop_refresh()
	-- body
	-- 0. success
	-- 1. offline
	-- 2. goods_refresh_count <= store_refresh_cout_max
	-- 3. not enought diamon
	-- 4. no need refresh
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "not online."
		return ret
	end
	assert(user)
	local t = os.date("*t", os.time())
	t = { year=t.year, month=t.month, day=t.day}
	local sec = os.time(t)
	local j = user.u_journalmgr:get_by_date(sec)
	if j then
		if j.goods_refresh_reset_count == 1 then
		else
			local hour = os.date("%H")
			local min = os.date("%M")
			local sec = os.date("%S")
			if tonumber(hour) > config.goods_refresh_reset_h then
				j.goods_refresh_count = 0
			end
		end
		if user.goods_refresh_count >= assert(user.store_refresh_count_max) then
			ret.errorcode = 2
			ret.msg = "more then store refresh count max"
			return ret
		end
	else
		t = os.date("*t", os.time())
		t = { year=t.year, month=t.month, day=t.day}
		local sec = os.time(t)
		t = { user_id=user.csv_id, date=sec, goods_refresh_count=0, goods_refresh_reset_count=0}
		j = user.u_journalmgr.create(t)
		user.u_journalmgr:add(j)
		j:__insert_db()
	end
	local goods = assert(game.g_goodsmgr:get_by_csv_id(self.goods_id))
	if goods.inventory ~= 0 then
		ret.errorcode = 4
		ret.msg = "no need refresh"
		return ret
	end
	if goods.currency_type == 1 then
		local rc = game.g_goods_refresh_costmgr:get_by_csv_id(j.goods_refresh_count + 1)
		local prop = user.u_propmgr:get_by_csv_id(rc.currency_type)
		if prop.num > rc.currency_num then
			prop.num = prop.num - rc.currency_num
			prop:__update_db({"num"})
			j.goods_refresh_count = j.goods_refresh_count + 1
			j:__update_db({"goods_refresh_count"})
			local goods = game.g_goodsmgr:get_by_csv_id(self.goods_id)
			goods.inventory = goods.inventory_init
			goods.countdown = goods.cd
			goods:__update_db({"inventory", "countdown"})
			ret.errorcode = 0
			ret.msg = "success"
			ret.l = { goods }
			return ret
		else
			ret.errorcode = 3
			ret.msg = "not enough diamond."
			return ret	
		end
	else
		assert(false)
	end
end

function REQUEST:shop_purchase()
	-- body
	-- 1 not online
	-- 2 not goods
	-- 3 not gold
	-- 4 not diamond
	-- 5 not inventory
	-- 6 other
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg	= "not online."
		return ret
	end
	assert(user)
	local l = skynet.call(".shop", "lua", "shop_purchase", self.g)
	local props = {}
	local gs = {}
	for k,v in pairs(l) do
		local goods = game.g_goodsmgr:get_by_csv_id(v.csv_id)
		if goods.currency_type == const.GOLD then
			local gold = goods.currency_num * v.p_num
			-- gold 2
			local currency = user.u_propmgr:get_by_csv_id(const.GOLD)
			if currency.num > gold then
				if goods.inventory == 99 then
				elseif goods.inventory == 0 then
					assert(goods.inventory == 0)
					local now = os.time()
					if now - goods.st > goods.cd then
						goods.inventory = goods.inventory_init
						if goods.inventory >= v.p_num then
							goods.inventory = goods.inventory - v.p_num
							if goods.inventory == 0 then
								goods.st = now
								goods:__update_db({"st", "inventory"})
							else
								goods:__update_db({"inventory"})
							end
						else
							ret.errorcode = 5
							ret.msg = "not inventory"
							return ret
						end
					else
						goods.countdown = now - goods.st
						goods:__update_db({"countdown"})
						ret.errorcode = 5
						ret.msg = "not inventory"
						return ret
					end
				elseif goods.inventory > 0 and goods.inventory >= v.p_num then
					goods.inventory = goods.inventory - v.p_num
					if goods.inventory == 0 then
						goods.st = os.time()
						goods:__update_db({"st", "inventory"})
					else
						goods:__update_db({"inventory"})
					end
				else
					assert(false)
				end
				currency.num = currency.num - gold
				currency:__update_db({"num"})
				local prop = user.u_propmgr:get_by_csv_id(goods.g_prop_csv_id)
				if prop then
					prop.num = prop.num + goods.g_prop_num * v.p_num
					prop:__update_db({"num"})
				else
					local p = game.g_propmgr:get_by_csv_id(goods.g_prop_csv_id)
					p.user_id = user.csv_id
					p.num = goods.g_prop_num * v.p_num
					local prop = user.u_propmgr.create(p)
					user.u_propmgr:add(prop)
					prop:__insert_db()
				end
				table.insert(props, prop)
				table.insert(gs, goods)
				local t = { user_id=user.csv_id, csv_id=goods.id, num=v.p_num, currency_type=const.GOLD, currency_num=gold, purchase_time=os.time()}
				local rc = user.u_purchase_goodsmgr.create(t)
				user.u_purchase_goodsmgr:add(rc)
				rc:__insert_db()
				ret.errorcode = 0
				ret.msg	= "yes, take gold"
				ret.l = props
				ret.ll = gs
				return ret
			else
				ret.errorcode = 3
				ret.msg	= string.format("yes, no enough gold, only %d", goods.gold)
				return ret
			end
		elseif goods.currency_type == const.DIAMOND then
			local diamond = goods.currency_num * v.p_num
			local currency = user.u_propmgr:get_by_csv_id(const.DIAMOND)
			if currency.num > diamond then
				if goods.inventory == 99 then
				elseif goods.inventory == 0 then
					assert(goods.inventory == 0)
					local now = os.time()
					if now - goods.st > goods.cd then
						goods.inventory = goods.inventory_init
						if goods.inventory >= v.p_num then
							goods.inventory = goods.inventory - v.p_num
							if goods.inventory == 0 then
								goods.st = now
								goods:__update_db({"st", "inventory"})
							else
								goods:__update_db({"inventory"})
							end
						else
							ret.errorcode = 5
							ret.msg = "not inventory"
							return ret
						end
					else
						goods.countdown = now - goods.st
						goods:__update_db({"countdown"})
						ret.errorcode = 5
						ret.msg = "not inventory"
						return ret
					end
				elseif goods.inventory > 0 and goods.inventory >= v.p_num then
					goods.inventory = goods.inventory - v.p_num
					if goods.inventory == 0 then
						goods.st = os.time()
						goods:__update_db({"st", "inventory"})
					else
						goods:__update_db({"inventory"})
					end
				else
					ret.errorcode = 5
					ret.msg = "not inventory"
					return ret
				end
				currency.num = currency.num - diamond
				currency:__update_db({"num"})
				local prop = user.u_propmgr:get_by_csv_id(goods.g_prop_csv_id)
				if prop then
					prop.num = prop.num + goods.g_prop_num * v.p_num
					prop:__update_db({"num"})
				else	
					prop = game.g_propmgr:get_by_csv_id(assert(goods.g_prop_csv_id))
					prop.user_id = user.csv_id
					prop.num = goods.g_prop_num * v.p_num
					prop = user.u_propmgr.create(prop)
					user.u_propmgr:add(prop)
					prop:__insert_db()
				end
				table.insert(props, prop)
				table.insert(gs, goods)
				local t = { user_id=user.csv_id, csv_id=goods.csv_id, num=v.p_num, currency_type=const.DIAMOND, currency_num=diamond, purchase_time=os.time()}
				local rc = user.u_purchase_goodsmgr.create(t)
				user.u_purchase_goodsmgr:add(rc)
				rc:__insert_db()
				ret.errorcode = 0
				ret.msg	= "yes, take diamond"
				return ret
			else
				ret.errorcode = 4
				ret.msg	= "no diamond"
				return ret
			end
		else
			ret.errorcode = 5
			ret.msg = "other"
			return ret
		end
	end
end

function REQUEST:recharge_all()
	-- body
	-- 0. success
	-- 1. offline
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "offline"
		return ret
	end
	ret.errorcode = 0
	ret.msg = "success"
	ret.l = skynet.call(".shop", "lua", "recharge_all")
	return ret
end

function REQUEST:recharge_purchase()
	-- body
	-- 0. success
	-- 1. offline
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "offline"
		return ret
	end
	assert(self.g)
	for i,v in ipairs(self.g) do
		local goods = assert(game.g_rechargemgr:get_by_csv_id(v.csv_id))
		assert(user.recharge_rmb)
		assert(user.recharge_diamond)
		user.recharge_rmb = user.recharge_rmb + goods.rmb * v.num
		user.recharge_diamond = user.recharge_diamond + goods.diamond * v.num
		user:__update_db({"recharge_rmb", "recharge_diamond"})
		local rc = user.u_recharge_countmgr:get_by_csv_id(v.csv_id)
		if rc then
			rc.count = rc.count + 1
			assert(rc.count > 1)
			rc:__update_db({"count"})
			local diamond = user.u_propmgr:get_by_csv_id(const.DIAMOND)
			diamond.num = diamond.num + ((goods.diamond + goods.gift) * v.num)
			diamond:__update_db({"num"})
		else
			rc = user.u_recharge_countmgr.create({user_id=user.csv_id, csv_id=v.csv_id, count=1})
			user.u_recharge_countmgr:add(rc)
			rc:__insert_db()
			local diamond = user.u_propmgr:get_by_csv_id(const.DIAMOND)
			diamond.num = diamond.num + (assert(goods.diamond) + assert(goods.first)) * v.num
			diamond:__update_db({"num"})
		end
		local t = {user_id=assert(user.csv_id), csv_id=assert(v.csv_id), num=assert(v.num), dt=os.time()}
		rr = user.u_recharge_recordmgr.create(t)
		user.u_recharge_recordmgr:add(rr)
		rr:__insert_db()

		-----------------------------
		repeat
			if user.uviplevel >= const.H_VIP then
				break
			end
			local condition = assert(game.g_recharge_vip_rewardmgr:get_by_vip(user.uviplevel + 1))
			local progress = user.recharge_diamond / condition.diamond
			if progress >= 1 then
				assert(user.exp_max)
				assert(user.gold_max)
				assert(user.exp_max)
				assert(user.equipment_enhance_success_rate_up_p)
				user.uviplevel = user.uviplevel + 1
				user.exp_max = user.exp_max + math.floor(user.exp_max * (condition.exp_max_up_p))
				user.gold_max = user.gold_max + math.floor(user.gold_max * (condition.gold_max_up_p))
				user.equipment_enhance_success_rate_up_p = assert(condition.equipment_enhance_success_rate_up_p)
				user.store_refresh_count_max = assert(condition.store_refresh_count_max)
				user.prop_refresh = user.prop_refresh - math.floor(user.prop_refresh * (condition.prop_refresh_reduction_p/100))
				user.arena_frozen_time = user.arena_frozen_time - math.floor(user.arena_frozen_time * (condition.arena_frozen_time_reduction_p/100))
				user.gain_exp_up_p = assert(condition.gain_exp_up_p)
				user.gain_gold_up_p = assert(condition.gain_gold_up_p)
				user:__update_db({	"uviplevel", 
									"exp_max", 
									"gold_max", 
									"equipment_enhance_success_rate_up_p", 
									"store_refresh_count_max", 
									"prop_refresh", 
									"arena_frozen_time",
									"gain_gold_up_p",
									"gain_gold_up_p"})
			else
				user.uvip_progress = progress * 100
				user:__update_db({"uvip_progress"})
				break
			end
		until false
	end
	ret.errorcode = 0
	ret.msg = "success"
	return ret
end

function REQUEST:recharge_vip_reward_all()
	-- body
	-- 0. success
	-- 1. offline
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "offline"
		return ret
	end
	assert(user)
	local l = {}
	for k,v in pairs(game.g_recharge_vip_rewardmgr.__data) do
		local r = {}
		r.vip = v.vip
		r.props = {}
		local t = util.parse_text(v.rewared, "%d+%*%d+%*?", 2)
		for i,v in ipairs(t) do
			table.insert(r.props, { csv_id=v[1], num=v[2]})
		end
		local reward = user.u_recharge_vip_rewardmgr:get_by_vip(v.vip)
		if reward then
			r.collected = (reward.collected == 1) and true or false
			r.purchased = (reward.purchased == 1) and true or false
		else
			r.collected = false
			r.purchased = false
		end
		table.insert(l, r)
	end
	ret.errorcode = 0
	ret.msg = "success"
	ret.reward = l
	return ret
end

function REQUEST:recharge_vip_reward_collect()
	-- body
	-- 0. success
	-- 1. offline
	-- 2. non-existent
	-- 3. error
	-- 4. have done
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "offline"
		return ret
	end
	if self.vip == 0 then
		ret.errorcode = 2
		ret.msg = "non-existent"
		return ret
	end
	if self.vip > user.uviplevel then
		ret.errorcode = 3
		ret.msg = "error"
		return ret
	end
	assert(user)
	local rc = user.u_recharge_vip_rewardmgr:get_by_vip(self.vip)
	if rc then
		if rc.collected == 1 then
			ret.errorcode = 4
			ret.msg = "have done"
			return ret
		else
			local reward = game.g_recharge_vip_rewardmgr:get_by_vip(self.vip)
			local t = util.parse_text(reward.rewared, "%d+%*%d+%*?", 2)
			for i,v in ipairs(t) do
				local prop = user.u_propmgr:get_by_csv_id(v[1])
				if prop then
					prop.num = prop.num + assert(v[2])
					prop:__update_db({"num"})
				else
					prop = assert(game.g_propmgr:get_by_csv_id(v[1]))
					prop.user_id = user.csv_id
					prop.num = assert(v[2])
					prop = user.u_propmgr.create(prop)
					user.u_propmgr:add(prop)
					prop:__insert_db()
				end
			end
			rc.collected = 1
			rc:__update_db({"collected"})
		end
	else
		local reward = game.g_recharge_vip_rewardmgr:get_by_vip(self.vip)
		local t = util.parse_text(reward.rewared, "%d+%*%d+%*?", 2)
		for i,v in ipairs(t) do
			local prop = user.u_propmgr:get_by_csv_id(v[1])
			if prop then
				prop.num = prop.num + assert(v[2])
				prop:__update_db({"num"})
			else
				prop = assert(game.g_propmgr:get_by_csv_id(v[1]))
				prop.user_id = user.csv_id
				prop.num = assert(v[2])
				prop = user.u_propmgr.create(prop)
				user.u_propmgr:add(prop)
				prop:__insert_db()
			end
		end
		local t = {user_id=user.csv_id, vip=self.vip, collected=1, purchased=0}	
		rc = user.u_recharge_vip_rewardmgr.create(t)
		user.u_recharge_vip_rewardmgr:add(rc)
		rc:__insert_db()
		ret.errorcode = 0
		ret.msg = "success"
		ret.vip = user.uviplevel
		ret.collected = true
		return ret
	end
end

function REQUEST:equipment_enhance()
	-- body
	-- 0. success
	-- 1. offline
	-- 2. don't have enough money.
	-- 3. rate
	-- 4. error.
	-- 5. do not exceed the level of the player
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "offline."
		return ret
	end
	local e = assert(user.u_equipmentmgr:get_by_csv_id(self.csv_id))
	if e.csv_id == 1 then
		local last = user.u_equipmentmgr:get_by_csv_id(4)
		print("*************", e.level, last.level)
		assert(tonumber(e.level) ~= tonumber(last.level))
	else
		local last = user.u_equipmentmgr:get_by_csv_id(e.csv_id - 1)
		assert(e.level < last.level)
	end
	local ee = game.g_equipment_enhancemgr:get_by_csv_id(e.csv_id *1000 + e.level + 1)
	if ee.level > user.level then
		ret.errorcode = 5
		ret.msg = "do not exceed the level of the player."
		return ret
	end
	local currency = user.u_propmgr:get_by_csv_id(ee.currency_type)
	if currency.num < ee.currency_num then
		ret.errorcode = 2
		ret.msg = "don't have enough money."
		return ret
	else
		assert(currency.num >= ee.currency_num)
		local r = math.random(0, 100)
		if r < e.enhance_success_rate then
			assert(currency.num > 0)
			currency.num = currency.num - ee.currency_num
			assert(currency.num > 0)
			currency:__update_db({"num"})
			e.level = ee.level
			e.combat = ee.combat
			e.defense = ee.defense
			e.critical_hit = ee.critical_hit
			e.king = ee.king
			e.combat_probability = ee.combat_probability
			e.critical_hit_probability = ee.critical_hit_probability
			e.defense_probability = ee.defense_probability
			e.king_probability = ee.king_probability
			e.enhance_success_rate = ee.enhance_success_rate
			e.currency_type = ee.currency_type
			e.currency_num = ee.currency_num
			e:__update_db({"level", "combat", "defense", "critical_hit_probability", "defense_probability", "king_probability", "enhance_success_rate", "currency_type", "currency_num"})
			ret.errorcode = 0
			ret.msg = "success"
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
			return ret
		else
			ret.errorcode = 3
			ret.msg = "enhance failture."
			return ret
		end
	end
end

function REQUEST:equipment_all()
	-- body
	-- 1 offline 
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "offline"
		return ret
	end
	local l = {}
	for k,v in pairs(user.u_equipmentmgr.__data) do
		local e = {
			csv_id = v.csv_id,
			level = v.level,
			combat = v.combat,
			defense = v.defense,
			critical_hit = v.critical_hit,
			king = v.king,
			combat_probability = v.combat_probability,
			critical_hit_probability = v.critical_hit_probability,
			defense_probability = v.defense_probability,
			king_probability = v.king_probability,
			enhance_success_rate = v.enhance_success_rate
		}
		table.insert(l, e)
	end
	ret.errorcode = 0
	ret.msg = "yes"
	ret.l = l
	return ret
end

function REQUEST:role_all()
	-- body
	-- 0. success
	-- 1. offline
	-- 2. 
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "offline"
		return ret
	end
	local l = {}
	for k,v in pairs(game.g_rolemgr.__data) do
		local role = {}
		role.csv_id = v.csv_id
		local r = user.u_rolemgr:get_by_csv_id(v.csv_id)
		if r then
			role.is_possessed = true
			role.star = r.star
			local prop = user.u_propmgr:get_by_csv_id(r.us_prop_csv_id)
			role.u_us_prop_num = prop and prop.num or 0
		else
			role.is_possessed = false
			role.star = v.star
			local prop = user.u_propmgr:get_by_csv_id(v.us_prop_csv_id)
			role.u_us_prop_num = prop and prop.num or 0
		end
		table.insert(l, role)
	end
	ret.errorcode = 0
	ret.msg = "success"
	ret.l = l
	-- ret.combat = 
 --    ret.defense =
 --    ret.critical_hit =
 --    ret.blessing =
    return ret
end

function REQUEST:role_recruit()
	-- body
	-- 0. success
	-- 1. offline
	-- 2. don't have enough
	local ret = {}
	if not ret then
		ret.errorcode = 1
		ret.msg = "offline"
		return ret
	end
	assert(self.csv_id)
	assert(user.u_rolemgr:get_by_csv_id(self.csv_id) == nil)
	local role = game.g_rolemgr:get_by_csv_id(self.csv_id)
	local us = assert(game.g_role_starmgr:get_by_csv_id(role.csv_id*1000+role.star))
	local prop = user.u_propmgr:get_by_csv_id(role.us_prop_csv_id)
	if prop and prop.num >= assert(us.us_prop_num) then
		prop.num = prop.num - us.us_prop_num
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
		role = user.u_rolemgr.create(role)
		user.u_rolemgr:add(role)
		role:__insert_db()
		ret.errorcode = 0
		ret.msg = "success"
		ret.r = {
			csv_id = role.csv_id,
			is_possessed = true,
			star = role.star,
			u_us_prop_num = prop.num
		}
		return ret
	else
		ret.errorcode = 2
		ret.msg = "don't have enough"
		return ret
	end
end

function REQUEST:role_battle()
	-- body
	-- 0. success
	-- 1. offline
	-- 2. 
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "offline"
		return ret
	end
	assert(self.csv_id)
	assert(user.u_propmgr:get_by_csv_id(self.csv_id))
	user.c_role_id = self.csv_id
	ret.errorcode = 0
	ret.msg = "success"
	return ret
end

function REQUEST:user_sign()
	-- body
	local ret = {}
	user.sign = self.sign
	user:__update_db({"sign"})
	ret.errorcode = 0
	ret.msg = "success"
	return ret
end

function REQUEST:user_random_name()
	-- body
	local ret = {}
	ret.errorcode = 0
	ret.msg = "success"
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
 		ret.errorcode = 1
 		ret.msg = "offline"
 		return ret
 	end
 	assert(self.vip)
 	assert(self.vip > 0)
 	if self.vip > user.uviplevel then
 		ret.errorcode = 2
 		ret.msg = "your vip don't"
 		return ret
 	end
 	local l = {}
 	local rc = user.u_recharge_vip_rewardmgr:get_by_vip(self.vip)
 	if rc then
 		if rc.purchased == 1 then
 			ret.errorcode = 3
 			ret.msg = "has purchased"
 			return ret
 		else
 			local reward = game.g_recharge_vip_rewardmgr:get_by_vip(self.vip)
 			local prop = user.u_propmgr:get_by_csv_id(const.DIAMOND)
 			if prop.num < reward.purchasable_diamond then
 				ret.errorcode = 2
 				ret.msg = "no enough diamond"
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
 					prop = assert(game.g_propmgr:get_by_csv_id(v[1]))
 					prop.user_id = user.csv_id
 					prop.num = assert(v[2])
 					prop = user.u_propmgr.create(prop)
 					user.u_propmgr:add(prop)
 					prop:__insert_db()
 					table.insert(l, { csv_id=prop.csv_id, num=prop.num})
 				end
 			end
 			rc.purchased = 1
 			rc:__update_db({"purchased"})
 			ret.errorcode = 0
 			ret.msg = "success"
 			ret.l = l
 			return ret
 		end
 	else
 		local reward = game.g_recharge_vip_rewardmgr:get_by_vip(self.vip)
 		local prop = user.u_propmgr:get_by_csv_id(const.DIAMOND)
 		if prop.num < reward.purchasable_diamond then
 			ret.errorcode = 2
 			ret.msg = "no enough diamond"
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
				prop = assert(game.g_propmgr:get_by_csv_id(v[1]))
				prop.user_id = user.csv_id
				prop.num = assert(v[2])
				prop = user.u_propmgr.create(prop)
				user.u_propmgr:add(prop)
				prop:__insert_db()
				table.insert(l, { csv_id=prop.csv_id, num=prop.num})
 			end
 		end
 		local t = { user_id=user.csv_id, vip=self.vip, collected=0, purchased=1}
 		rc = user.u_recharge_vip_rewardmgr.create(t)
 		user.u_recharge_vip_rewardmgr:add(rc)
 		rc:__insert_db()
 		ret.errorcode = 0
 		ret.msg = "success"
 		ret.l = l
 		return ret
 	end
end

function REQUEST:handshake()
	print("Welcome to skynet, I will send heartbeat every 5 sec." )
	return { msg = "Welcome to skynet, I will send heartbeat every 5 sec." }
end		

function REQUEST:quit()
	skynet.call(WATCHDOG, "lua", "close", client_fd)
end

local function request(name, args, response)
    local f = nil
    if REQUEST[name] ~= nil then
    	f = assert(REQUEST[name])
    --elseif nil ~= emailrequest[ name ] then
    --	f = assert( emailrequest[ name ] )
    elseif nil ~= friendrequest[ name ] then
    	f = assert( friendrequest[ name ] )
    --elseif nil ~= drawrequest[ name ] then
    --	f = assert( drawrequest[ name ] )
    else
    	for i,v in ipairs(M) do
    		if v.REQUEST[name] ~= nil then
    			f = v.REQUEST[name]
    			break
    		end
    	end
    end
    assert(f)
    local r = f(args)
    print("**********************************", name)
    if name == "login" then
    	if r.errorcode == 0 then
    		for k,v in pairs(M) do
    			if v.REQUEST then
    				v.REQUEST[name](v.REQUEST, user)
    			end
    		end
    	end
    end
    if response then
    	return response(r)
    end               
end      

function RESPONSE:finish_achi( ... )
	-- body
	assert(self.errorcode == 0)
	skynet.error(self.msg)
end

local function response( name, args )
	-- body
	local f = assert(RESPONSE[name])
	f(args)
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
	dispatch = function (_, _, type, ...)
		if type == "REQUEST" then
			local ok, result  = pcall(request, ...)
			if ok then
				if result then
					send_package(result)
				end
			else
				skynet.error(result)
			end
		elseif type == "HEARTBEAT" then
			send_package(send_request "heartbeat")
		elseif type == "RESPONSE" then
			pcall(response, ...)
		end
	end
}	
	
function CMD.start(conf)
	print("start is called")
	local fd = conf.client
	local gate = conf.gate
	WATCHDOG = conf.watchdog
	-- slot 1,2 set at main.lua
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))
	-- skynet.fork(function()
	-- 	while true do
	-- 		send_package(send_request "heartbeat")
	-- 		skynet.sleep(500)
	-- 	end
	-- end)
	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)

	game = loader.load_game()
	
	for i,v in ipairs(M) do
		v.start(conf, send_request, game)
	end
end	
	   
function CMD.disconnect()
	-- todo: do something before exit
	if user then
		user.ifonline = 0
		user:__update_db({"ifonline"})
		dc.set( user.csv_id , nil )
		user = nil
	end
	skynet.exit()
end	

function CMD.friend( subcmd, ... )
	-- body
	local f = assert(friendrequest[subcmd])
	local r =  f(friendrequest, ...)

	if r ~= nil then
		print( "r os  sdddddddddddddddddddddddddddddddddddddddm nil" )
		return r
	end
end

function CMD.newemail( subcmd , ... )
	local f = assert( new_emailrequest[ subcmd ] )
	f( new_emailrequest , ... )
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		print("agent is called" , command)
		local f = CMD[command]
		local result = f( ... )
		if result then
			skynet.ret(skynet.pack(result))
		end
	end)
end)
