package.path = "./../cat/?.lua;" .. package.path
package.cpath = "./../cat/luaclib/?.so;" .. package.cpath
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
local const = require "const"
local config = require "config"
local tptr = require "tablepointer"

local friendrequest = require "friendrequest"
local friendmgr = require "friendmgr"
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
local G
	  
local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

local function flush_db(priority)
	-- body
	if user then
		for k,v in pairs(user) do
			if string.match(k, "^u_%w+mgr$") then
				v:update_db(priority)
			end
		end
		user:__update_db({"uaccount", "upassword", "uviplevel", "config_sound", "config_music", 
			"avatar", "sign", "c_role_id", "ifonline", "level", 
			"combat", "defense", "critical_hit", "blessing", "modify_uname_count", "onlinetime", 
			"iconid", "is_valid", "recharge_rmb", "recharge_diamond", "uvip_progress", 
			"checkin_num", "checkin_reward_num", "exercise_level", "cgold_level", "gold_max",
			"exp_max", "equipment_enhance_success_rate_up_p", "store_refresh_count_max",
			"prop_refresh", "arena_frozen_time", "purchase_hp_count", "gain_gold_up_p", "gain_exp_up_p",
			"purchase_hp_count_max", "SCHOOL_reset_count_max", "SCHOOL_reset_count"}, priority)
	end
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

local function raise_achievement(type, user)
	-- body
	if type == "combat" then
	elseif type == const.A_T_GOLD then -- 2
		repeat
			local a = assert(user.u_achievementmgr:get_by_type(const.A_T_GOLD))
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
					
					local a1 = skynet.call(game, "lua", "query_g_achievement", tonumber(k1))
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
						local ga = skynet.call(game, "lua", "query_g_achievement", tonumber(k2))
						a.csv_id = ga.csv_id
						a.finished = 0
						a.c_num = ga.c_num
						a.unlock_next_csv_id = ga.unlock_next_csv_id
						-- a.is_unlock = 1
						a:__update_db({"csv_id", "finished", "c_num", "unlock_next_csv_id", "is_valid"})	
					end
				else
					local ga = skynet.call(game, "lua", "query_g_achievement", tonumber(a.unlock_next_csv_id))
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
					
					local a1 = skynet.call(game, "lua", "query_g_achievement", tonumber(k1))
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
						local ga = skynet.call(game, "lua", "query_g_achievement", tonumber(k2))
						a.csv_id = ga.csv_id
						a.finished = 0
						a.c_num = ga.c_num
						a.unlock_next_csv_id = ga.unlock_next_csv_id
						-- a.is_unlock = 1
						a:__update_db({"csv_id", "finished", "c_num", "unlock_next_csv_id", "is_valid"})	
					end
				else
					local ga = skynet.call(game, "lua", "query_g_achievement", tonumber(a.unlock_next_csv_id))
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

local function get_journal()
	-- body
	local t = os.date("*t", os.time())
	t = { year=t.year, month=t.month, day=t.day}
	local sec = os.time(t)
	local j = user.u_journalmgr:get_by_date(sec)
	if j then
		return j
	else
		t = { user_id=user.csv_id, date=sec, goods_refresh_count=0, goods_refresh_reset_count=0}
		j = user.u_journalmgr.create(t)
		user.u_journalmgr:add(j)
		j:__insert_db()
		return j
	end
end

local function get_prop(csv_id)
	-- body
	print("get_prop", csv_id)
	local p = user.u_propmgr:get_by_csv_id(csv_id)
	if p then
		return p
	else
		p = skynet.call(game, "lua", "query_g_prop", csv_id)
		p.user_id = user.csv_id
		p.num = 0
		p = user.u_propmgr.create(p)
		user.u_propmgr:add(p)
		p:__insert_db()
		return p
	end
end

local function get_goods(csv_id)
	-- body
	local p = user.u_goodsmgr:get_by_csv_id(csv_id)
	if p then
		return p
	else
		p = skynet.call(game, "lua", "query_g_goods", csv_id)
		p.user_id = user.csv_id
		p.inventory = p.inventory_init
		p.countdown = 0
		p.st = 0
		p = user.u_goodsmgr.create(p)
		user.u_goodsmgr:add(p)
		p:__insert_db()
	end
end

local function store_refresh_reset_count()
	-- body
	-- could refresh the cd of the goods.
	local j = get_journal()
	if j.goods_refresh_reset_count ~= 1 then
		local hour = os.date("%H")
		local min = os.date("%M")
		local sec = os.date("%S")
		if tonumber(hour) > config.goods_refresh_reset_h then
			j.goods_refresh_count = 0
			j.goods_refresh_reset_count = 1
			j:__update_db({"goods_refresh_count", "goods_refresh_reset_count"})
		end
	end
end

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

function REQUEST:achievement()
	-- body
	-- 1 not online
	-- 2
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	local function decorate(v, a)
		-- body
		local cur = assert(user.u_achievementmgr:get_by_type(v.type))
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
		end
		return a
	end
	local l = {}
	local r = skynet.call(game, "lua", "query_g_achievement")
	for k,v in pairs(r) do
		local a = {}
		a.csv_id = v.csv_id
		decorate(v, a)
		table.insert(l, a)
	end
	ret.errorcode = errorcode[1].code
    ret.msg = errorcode[1].msg
    ret.achis = l
    return ret
end

function REQUEST:achievement_reward_collect()
	-- body
	-- 0. success
	-- 1. offline
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	assert(self.csv_id)
	local a = user.u_achievement_rcmgr:get_by_csv_id(self.csv_id)
	if a and a.finished == 100 and a.reward_collected == 0 then
		a.reward_collected = 1
		a:__update_db({"reward_collected"})
		local a_src = skynet.call(game, "lua", "query_g_achievement", a.csv_id)
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
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		return ret
	end
	ret.errorcode = errorcode[26].code
	ret.msg = errorcode[26].msg
	return ret
end
    
function REQUEST:signup()
	-- body
	local ret = {}
	if #self.account == 0 or #self.password == 0 then
		ret.errorcode = errorcode[12].code
		ret.msg = errorcode[12].msg
		return ret
	end
	local condition = {{ uaccount = self.account}}
	-- local addr = util.random_db()
	local addr = ".db2"
	local r = skynet.call(addr, "lua", "command", "select", "users", condition)
	if #r == 0 then
		local level = skynet.call(game, "lua", "query_g_user_level", 1)
		local vip = skynet.call(game, "lua", "query_g_recharge_vip_reward", 0)
		-- create an user
		local t = { csv_id= skynet.call(game, "lua", "guid", const.UENTROPY),
				uname="nihao",
				uaccount=self.account, 
				upassword=self.password,
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
				SCHOOL_reset_count=0,
				signup_time=os.time() }
		local usersmgr = require "models/usersmgr"
		local u = usersmgr.create(t)
		u:__insert_db()

		-- create
		local u_equipmentmgr = require "models/u_equipmentmgr"
		local l = {}
		local r = skynet.call(game, "lua", "query_g_equipment")
		for k,v in pairs(r) do
			local equip = skynet.call(game, "lua", "query_g_equipment_enhance", v.csv_id*1000+v.level)
			equip.user_id = u.csv_id
			local equip = u_equipmentmgr.create(equip)
			table.insert(l, equip)
		end
		u_equipmentmgr.insert_db(l)

		l = {}
		local u_propmgr = require "models/u_propmgr"
		local prop = skynet.call(game, "lua", "query_g_prop", const.GOLD)
		prop.user_id = u.csv_id
		prop.num = 100
		prop = u_propmgr.create(prop)
		table.insert(l, prop)

		prop = skynet.call(game, "lua", "query_g_prop", const.DIAMOND)
		prop.user_id = u.csv_id
		prop.num = 100
		prop = u_propmgr.create(prop)
		table.insert(l, prop)

		prop = skynet.call(game, "lua", "query_g_prop", const.EXP)
		prop.user_id = u.csv_id
		prop.num = 100
		prop = u_propmgr.create(prop)
		table.insert(l, prop)
		
		prop = skynet.call(game, "lua", "query_g_prop", const.LOVE)
		prop.user_id = u.csv_id
		prop.num = 100     
		prop = u_propmgr.create(prop)
		table.insert(l, prop)
		u_propmgr.insert_db(l)
		
		local newemail = { 
						   type = 1 , title = "new user email" , 
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
		local role = skynet.call(game, "lua", "query_g_role", 1)
		local role_star = skynet.call(game, "lua", "query_g_role_star", role.csv_id*1000+role.star)
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

		-- achievement
		l = {}
		local u_achievementmgr = require "models/u_achievementmgr"
		local a = skynet.call(game, "lua", "query_g_achievement", 1001)
		a.user_id = u.csv_id
		a.finished = 0
		a.reward_collected = 0
		a.is_unlock = 1
		a.is_valid = 1
		a = u_achievementmgr.create(a)
		table.insert(l, a)
		a = skynet.call(game, "lua", "query_g_achievement", 2001)
		a.user_id = u.csv_id
		a.finished = 0
		a.reward_collected = 0
		a.is_unlock = 1
		a.is_valid = 1
		a = u_achievementmgr.create(a)
		table.insert(l, a)
		u_achievementmgr.insert_db(l)

		local u_goodsmgr = require "models/u_goodsmgr"
		local r = skynet.call(game, "lua", "query_g_goods")
		l = {}
		for k,v in pairs(r) do
			local t = { user_id = u.csv_id, csv_id=v.csv_id, inventory=v.inventory_init, countdown=0, st=0}
			local a = u_goodsmgr.create(t)
			table.insert(l, a)
		end
		u_goodsmgr.insert_db(l)

		ret.errorcode = errorcode[1].code
		ret.msg	= errorcode[1].msg
		return ret
	else
		ret.errorcode = errorcode[13].code
		ret.msg = errorcode[13].msg
		return ret
	end 
end 	
    	
local function get_public_email()
	local r = skynet.call( ".channel" , "lua" , "agent_get_public_email" , user.csv_id , user.pemail_csv_id , user.signup_time )
	assert( r )

	for k , v in ipairs( r ) do
		assert( v and v.pemail_csv_id )
		
		user.pemail_csv_id = v.pemail_csv_id
		user:__update_db( { "pemail_csv_id" } )

		v.pemail_csv_id = nil
		new_emailrequest:public_email( v , user )
	end 
end    	
	 	
function REQUEST:login()
	assert((#self.account > 1 and #self.password > 1), string.format("from client account:%s, password:%s incorrect.", self.account, self.password))
	local ret = {}
	if user then
		if user.uaccount == self.account and user.upassword == self.password then
			ret.errorcode  = errorcode[14].code
			ret.msg = errorcode[14].msg
			return ret
		else
			user.ifonline = 0
			flush_db()
			dc.set(user.csv_id, nil)
			loader.clear(user)
			user = nil
		end
	end
	local condition = {{ uaccount = self.account, upassword = self.password }}
	local addr = util.random_db()
	local r = skynet.call(addr, "lua", "command", "select", "users", condition)
	if #r == 0  then
		ret.errorcode = errorcode[15].code
		ret.msg = errorcode[15].msg
		return ret
	elseif #r == 1 then
		local usersmgr = require "models/usersmgr"
		user = usersmgr.create(r[1])
		if dc.get(user.csv_id) then
			skynet.error("user %d is logged in the agent %d", user.csv_id, dc.get(user.csv_id).addr)
			user = nil
			ret.errorcode = errorcode[14].code
			ret.msg = errorcode[14].msg
			return ret
		end

		dc.set(user.csv_id, { client_fd=client_fd, addr=skynet.self()})
		loader.load_user(user)
		subscribe()
		skynet.fork(subscribe)

		local onlinetime = os.time()
		user.ifonline = 1
		user.onlinetime = onlinetime
		user:__update_db({"ifonline", "onlinetime"})
		user.friendmgr = friendmgr:loadfriend( user , dc )
		friendrequest.getvalue(user, send_package, send_request)

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
			recharge_total = user.recharge_rmb,
    		recharge_diamond = user.recharge_diamond,
    		recharge_progress = user.uvip_progress,
    		level = assert(user.level)
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
		return ret
	else
		assert(false)
	end 
end	

function REQUEST:logout()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	flush_db()
	loader.clear( user )
	user.ifonline = 0
	user:__update_db({"ifonline"})
	dc.set(user.csv_id , nil)
	user = nil
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	return ret
end

function REQUEST:role_info()
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	assert(self.role_id)
	local role = assert(user.u_rolemgr:get_by_csv_id(self.role_id))
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.r = { csv_id = role.csv_id,
			is_possessed = true,
			star = role.star }
	local prop = user.u_propmgr:get_by_csv_id(role.us_prop_csv_id)
	if prop then
		ret.r.u_us_prop_num = prop.num
	else
		ret.r.u_us_prop_num = 0
	end
	return ret
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
		prop:__update_db({"num"})
		role.star = role_star.star
		-- role.us_prop_csv_id = assert(role_star.us_prop_csv_id)
		role.us_prop_num = assert(role_star.us_prop_num)
		role.sharp = assert(role_star.sharp)
		role.skill_csv_id = assert(role_star.skill_csv_id)
		role.gather_buffer_id = assert(role_star.gather_buffer_id)
		role.battle_buffer_id = assert(role_star.battle_buffer_id)
		role:__update_db({"star", "us_prop_num", "sharp", "skill_csv_id", "gather_buffer_id", "battle_buffer_id"})
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

function REQUEST:props()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	local l = {}
	for k,v in pairs(user.u_propmgr.__data) do
		table.insert(l, v)
	end
	ret.l = l
	return ret
end

function REQUEST:use_prop()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	assert(#self.props == 1)
	local l = {}
	local prop = assert(get_prop(self.props[1].csv_id))
	if self.props[1].num > 0 then
		-- get
		prop.num = prop.num + v.num
		prop.__update_db({"num"})
		table.insert(l, prop)
	elseif self.props[1].num < 0 then
		-- consume
		local num = math.abs(self.props[1].num)
		if prop.num < num then
			ret.errorcode = errorcode[16].code
			ret.msg = errorcode[16].msg
			return ret
		end
		prop.num = prop.num + self.props[1].num
		prop:__update_db({"num"})
		table.insert(l, prop)
		if assert(prop.use_type) == 0 then
			ret.errorcode = errorcode[28].code
			ret.msg = errorcode[28].msg
			return ret
		elseif assert(prop.use_type) == 1 then -- exp 
			local e = user.u_propmgr:get_by_csv_id(const.EXP)
			e.num = e.num + (tonumber(prop.pram1) * num)
			e:__update_db({"num"})
			table.insert(l, e)
			raise_achievement(const.A_T_EXP, user)
		elseif assert(prop.use_type) == 2 then -- gold
			local g = user.u_propmgr:get_by_csv_id(const.GOLD)
			g.num = g.num + (tonumber(prop.pram1) * num)
			g:__update_db({"num"})
			table.insert(l, g)
			raise_achievement(const.A_T_GOLD, user)
		elseif assert(prop.use_type) == 3 then
			local r = util.parse_text(prop.pram1, "(%d+%*%d+%*?)", 2)
			print("length of r", #r)
			for k,v in pairs(r) do
				if v[1] == const.GOLD then
					local prop = user.u_propmgr:get_by_csv_id(const.GOLD)
					prop.num = prop.num + (v[2] * num)
					prop:__update_db({"num"})
					table.insert(l, prop)
					raise_achievement(const.A_T_GOLD, user)
				elseif v[1] == const.EXP then
					local prop = user.u_propmgr:get_by_csv_id(v[1])
					prop.num = prop.num + (v[2] * num)
					prop:__update_db({"num"})
					table.insert(l, prop)
					raise_achievement(const.A_T_EXP, user)
				else
					local prop = get_prop(v[1])
					prop.num = prop.num + (v[2] * num)
					prop:__update_db({"num"})
					table.insert(l, prop)
				end
			end
		elseif assert(prop.use_type) == 4 then
			local f = false
			local r = util.parse_text(prop.pram1, "(%d+%*%d+%*%d+%*?)", 3)
			local total = 0
			for i,v in ipairs(r) do
				v.min = total
				total = total + assert(v[3])
				v.max = total
			end
			local rand = math.random(1, total-1)
			for i,v in ipairs(r) do
				if rand >= v.min and rand < v.max then
					f = true
					local prop = assert(get_prop(v[1]))
					prop.num = prop.num + (v[2] * num)
					prop:__update_db({"num"})
					table.insert(l, prop)
					break
				end
			end
			assert(f)
		end	
	else
		ret.errorcode = errorcode[27].code
		ret.msg = errorcode[27].msg
		return ret
	end
	ret.errorcode = errorcode[1].code
	ret.msg	= errorcode[1].msg
	ret.props = l
	return ret
end

function REQUEST:user()
	-- body
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
    	recharge_progress = user.uvip_progress,
    	level = user.level
	}
	ret.user.uexp = assert(user.u_propmgr:get_by_csv_id(const.EXP)).num
	ret.user.gold = assert(user.u_propmgr:get_by_csv_id(const.GOLD)).num
	ret.user.diamond = assert(user.u_propmgr:get_by_csv_id(const.DIAMOND)).num
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
			prop:__update_db({"num"})
			user.uname = self.name
			user.modify_uname_count = user.modify_uname_count + 1
			user:__update_db({"modify_uname_count", "uname"})
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
		user:__update_db({"modify_uname_count", "uname"})
		ret.errorcode = errorcode[1].code
		ret.msg = errorcode[1].msg
		return ret
	end
end

function REQUEST:user_upgrade()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	local user_level_max
	local ptr = skynet.call(game, "lua", "query_g_config")
	tptr.createtable(ptr)
	for _,k,v in tptr.pairs(ptr) do
		if k == "user_level_max" then
			user_level_max = v
			break
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
			prop:__update_db({"num"})
			user.level = L.level
			user.combat = L.combat
			user.defense = L.defense
			user.critical_hit = L.critical_hit
			user.blessing = L.skill              -- blessing.
			user.gold_max = assert(L.gold_max)
			user.exp_max = assert(L.exp_max)
			-- user:__update_db({ "level", "combat", "defense", "critical_hit", "blessing", "gold_max", "exp_max"})
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

function REQUEST:shop_all()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg	= errorcode[2].msg
		return ret
	end
	assert(user)
	local r = skynet.call(game, "lua", "query_g_goods")
	local ll = {}
	for k,v in pairs(r) do
		local tmp = user.u_goodsmgr:get_by_csv_id(v.csv_id)
		if tmp then
			if tmp.inventory == 0 then
				local now = os.time()
				local walk = os.difftime(now, tmp.st)
				if walk > v.cd then
					tmp.inventory = v.inventory_init
					tmp.countdown = 0
					tmp.st = 0
					tmp:__update_db({"inventory", "countdown", "st"})
				else
					tmp.countdown = v.cd - walk
					tmp:__update_db({"countdown"})
				end
			end
		else
			v.user_id = user.csv_id
			v.inventory = v.inventory_init
			v.countdown = 0
			v.st = 0
			tmp = user.u_goodsmgr.create(v)
			user.u_goodsmgr:add(tmp)
			tmp:__insert_db()
		end
		for kk,vv in pairs(tmp) do
			v[kk] = vv
		end
		table.insert(ll, v)
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.l = ll
	ret.goods_refresh_count = assert(get_journal().goods_refresh_count)
	ret.store_refresh_count_max = assert(user.store_refresh_count_max)
	return ret
end

function REQUEST:shop_refresh()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	local j = assert(get_journal())
	local gg = assert(skynet.call(game, "lua", "query_g_goods", self.goods_id))
	local ug = user.u_goodsmgr:get_by_csv_id(self.goods_id)
	if ug.inventory == 0 then
		local now = os.time()
		local walk = now - ug.st
		if walk < gg.cd then
			-- judge refersh count
			print("****8ajfal", j.goods_refresh_count, user.store_refresh_count_max)
			if j.goods_refresh_count >= assert(user.store_refresh_count_max) then
				ug.countdown = gg.cd - walk
				ug:__update_db({ "countdown"})
				ret.errorcode = errorcode[5].code
				ret.msg = errorcode[5].msg
				ret.l = { goods}
				ret.goods_refresh_count  = assert(j.goods_refresh_count)
				ret.store_refresh_count_max = assert(user.store_refresh_count_max)
				return ret
			end
			local rc = assert(skynet.call(game, "lua", "query_g_goods_refresh_cost", j.goods_refresh_count + 1))
			local prop = get_prop(rc.currency_type)
			if prop.num > rc.currency_num then
				print("abc")
				prop.num = prop.num - rc.currency_num
				prop:__update_db({"num"})
				j.goods_refresh_count = j.goods_refresh_count + 1
				j:__update_db({"goods_refresh_count"})
				ug.inventory = gg.inventory_init
				ug.countdown = 0
				ug.st = 0
				ug:__update_db({"inventory", "countdown", "st"})
				ret.errorcode = errorcode[1].code
				ret.msg = errorcode[1].msg
				for k,v in pairs(ug) do
					gg[k] = ug[k]
				end
				ret.l = { gg }
				ret.goods_refresh_count = assert(j.goods_refresh_count)
				ret.store_refresh_count_max = assert(user.store_refresh_count_max)
				return ret
			else
				print("chjalkf")
				goods.countdown = gg.cd - walk
				goods:__update_db({"countdown"})
				for k,v in pairs(ug) do
					gg[k] = ug[k]
				end
				ret.errorcode = errorcode[6].code
				ret.msg = errorcode[6].msg
				ret.l = { gg}
				ret.goods_refresh_count = assert(j.goods_refresh_count)
				ret.store_refresh_count_max = assert(user.store_refresh_count_max)
				return ret	
			end
		else
			ug.inventory = gg.inventory_init
			ug.countdown = gg.cd - walk
			ug:__update_db({"inventory", "countdown"})
			for k,v in pairs(ug) do
				gg[k] = ug[k]
			end
			ret.errorcode = errorcode[7].code
			ret.msg = errorcode[7].msg
			ret.l = { goods}
			ret.goods_refresh_count = assert(j.goods_refresh_count)
			ret.store_refresh_count_max = assert(user.store_refresh_count_max)
			return ret
		end
	else
		assert(ug.inventory > 0)
		ret.errorcode = errorcode[8].code
		ret.msg = errorcode[8].msg
		for k,v in pairs(ug) do
			gg[k] = ug[k]
		end
		ret.l = { gg }
		ret.goods_refresh_count = assert(j.goods_refresh_count)
		ret.store_refresh_count_max = assert(user.store_refresh_count_max)
		return ret
	end
end

function REQUEST:shop_purchase()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg	= errorcode[2].msg
		return ret
	end
	assert(user)
	assert(self.g)
	local gg = skynet.call(game, "lua", "query_g_goods", self.g[1].goods_id)
	local ug = user.u_goodsmgr:get_by_csv_id(gg.csv_id)
	if gg.currency_type == const.GOLD then
		local gold = gg.currency_num * self.g[1].goods_num
		local currency = user.u_propmgr:get_by_csv_id(const.GOLD)
		if currency.num >= gold then
			if ug.inventory == 0 then
				local now = os.time()
				local countdown = os.difftime(now, goods.st)
				if countdown > goods.cd then
					ug.inventory = ug.inventory_init
					ug.countdown = 0
					ug:__update_db({"inventory", "countdown"})
				else
					ug.countdown = countdown
					ug:__update_db({"countdown"})
					ret.errorcode = errorcode[10].code
					ret.msg = errorcode[10].msg
					ret.goods_refresh_count = assert(j.goods_refresh_count)
					ret.store_refresh_count_max = assert(user.store_refresh_count_max)
					return ret
				end
				if ug.inventory > self.g[1].goods_num then
					ug.inventory = ug.inventory - self.g[1].goods_num
					if ug.inventory == 0 then
						ug.countdown = gg.cd
						ug.st = os.time()
						ug:__update_db({"inventory", "countdown", "st"})
					else
						ug:__update_db({"inventory"})	
					end

					currency.num = currency.num - gold
					currency:__update_db({"num"})
					local prop = get_prop(gg.g_prop_csv_id)
					prop.num = prop.num + (gg.g_prop_num * self.g[1].goods_num)
					prop:__update_db({"num"})

					ret.errorcode = errorcode[1].code
					ret.msg = errorcode[1].msg
					ret.ll = { goods}
					ret.l = { prop}
					local j = assert(get_journal())
					ret.goods_refresh_count = assert(j.goods_refresh_count)
					ret.store_refresh_count_max = assert(user.store_refresh_count_max)
					return ret
				else
					ret.errorcode = errorcode[11].code
					ret.msg = errorcode[11].msg
					local j = assert(get_journal())
					ret.goods_refresh_count = assert(j.goods_refresh_count)
					ret.store_refresh_count_max = assert(user.store_refresh_count_max)
					return ret
				end
			elseif ug.inventory == 99 then
				currency.num = currency.num - gold
				currency:__update_db({"num"})
				local prop = get_prop(gg.g_prop_csv_id)
				prop.num = prop.num + (gg.g_prop_num * self.g[1].goods_num)
				prop:__update_db({"num"})

				ret.errorcode = errorcode[1].code
				ret.msg = errorcode[1].msg
				for k,v in pairs(ug) do
					gg[k] = ug[k]
				end
				ret.ll = { gg}
				ret.l = { prop}
				local j = assert(get_journal())
				ret.goods_refresh_count = assert(j.goods_refresh_count)
				ret.store_refresh_count_max = assert(user.store_refresh_count_max)
				return ret
			else
				assert(ug.inventory > 0)
				if ug.inventory > self.g[1].goods_num then
					ug.inventory = ug.inventory - self.g[1].goods_num
					if ug.inventory == 0 then
						ug.countdown = gg.cd
						ug.st = os.time()
						ug:__update_db({"inventory", "countdown", "st"})
					else
						ug:__update_db({"inventory"})
					end
					currency.num = currency.num - gold
					currency:__update_db({"num"})
					
					local prop = get_prop(gg.g_prop_csv_id)
					prop.num = prop.num + (gg.g_prop_num * self.g[1].goods_num)
					prop:__update_db({"num"})

					ret.errorcode = errorcode[1].code
					ret.msg = errorcode[1].msg
					ret.ll = { goods}
					ret.l = { prop}
					local j = assert(get_journal())
					ret.goods_refresh_count = assert(j.goods_refresh_count)
					ret.store_refresh_count_max = assert(user.store_refresh_count_max)
					return ret
				else
					ret.errorcode = errorcode[11].code
					ret.msg = errorcode[11].msg
					local j = assert(get_journal())
					ret.goods_refresh_count = assert(j.goods_refresh_count)
					ret.store_refresh_count_max = assert(user.store_refresh_count_max)
					return ret
				end
			end
		else
			ret.errorcode = errorcode[9].code
			ret.msg = errorcode[9].msg
			local j = assert(get_journal())
			ret.goods_refresh_count = assert(j.goods_refresh_count)
			ret.store_refresh_count_max = assert(user.store_refresh_count_max)
			return ret
		end
	elseif gg.currency_type == const.DIAMOND then
		local diamond = gg.currency_num * self.g[1].goods_num
		local currency = user.u_propmgr:get_by_csv_id(const.DIAMOND)
		if currency.num >= diamond then
			if ug.inventory == 0 then
				local now = os.time()
				local walk = os.difftime(now, ug.st)
				print("************abcd", now, ug.st, countdown)
				if walk > gg.cd then
					ug.inventory =gg.inventory_init
					ug.countdown = 0
					ug:__update_db({"inventory", "countdown"})
					if self.g[1].goods_num <= ug.inventory then
						ug.inventory = ug.inventory - self.g[1].goods_num
						ug:__update_db({"inventory"})
						currency.num = currency.num - diamond
						currency:__update_db({"num"})
						local prop = get_prop(gg.g_prop_csv_id)
						prop.num = prop.num + (gg.g_prop_num * self.g[1].goods_num)
						prop:__update_db({"num"})
						ret.errorcode = errorcode[1].code
						ret.msg = errorcode[1].msg
						ret.l = { prop}
						for k,v in pairs(ug) do
							gg[k] = ug[k]
						end
						ret.ll = { gg}
						local j = assert(get_journal())
						ret.goods_refresh_count = assert(j.goods_refresh_count)
						ret.store_refresh_count_max = assert(user.store_refresh_count_max)
						return ret	
					else
						ret.errorcode = errorcode[11].code
						ret.msg = errorcode[11].msg
						local j = assert(get_journal())
						ret.goods_refresh_count = assert(j.goods_refresh_count)
						ret.store_refresh_count_max = assert(user.store_refresh_count_max)	
						return ret
					end
				else
					ug.countdown = gg.cd - walk
					ug:__update_db({"countdown"})
					ret.errorcode = errorcode[10].code
					ret.msg = errorcode[10].msg
					ret.ll = { goods}
					local j = assert(get_journal())
					ret.goods_refresh_count = assert(j.goods_refresh_count)
					ret.store_refresh_count_max = assert(user.store_refresh_count_max)
					return ret
				end
			elseif ug.inventory == 99 then
				currency.num = currency.num - diamond
				currency:__update_db({"num"})
				local prop = get_prop(gg.g_prop_csv_id)
				prop.num = prop.num + (gg.g_prop_num * self.g[1].goods_num)
				prop:__update_db({"num"})
				ret.errorcode = errorcode[1].code
				ret.msg = errorcode[1].msg
				ret.l = { prop}
				for k,v in pairs(ug) do
					gg[k] = ug[k]
				end
				ret.ll = { gg}
				local j = assert(get_journal())
				ret.goods_refresh_count = assert(j.goods_refresh_count)
				ret.store_refresh_count_max = assert(user.store_refresh_count_max)	
				return ret
			else
				assert(ug.inventory > 0)
				if self.g[1].goods_num <= ug.inventory then
					ug.inventory = ug.inventory - self.g[1].goods_num
					if ug.inventory == 0 then
						ug.countdown = gg.cd
						ug.st = os.time()
						ug:__update_db({"inventory", "countdown", "st"})
					else
						ug:__update_db({"inventory"})	
					end
					currency.num = currency.num - diamond
					currency:__update_db({"num"})
					local prop = get_prop(gg.g_prop_csv_id)
					prop.num = prop.num + (gg.g_prop_num * self.g[1].goods_num)
					prop:__update_db({"num"})
					ret.errorcode = errorcode[1].code
					ret.msg = errorcode[1].msg
					ret.l = { prop}
					for k,v in pairs(ug) do
						gg[k] = ug[k]
					end
					ret.ll = { gg}
					local j = assert(get_journal())
					ret.goods_refresh_count = assert(j.goods_refresh_count)
					ret.store_refresh_count_max = assert(user.store_refresh_count_max)	
					return ret
				else
					ret.errorcode = errorcode[11].code
					ret.msg = errorcode[11].msg
					local j = assert(get_journal())
					ret.goods_refresh_count = assert(j.goods_refresh_count)
					ret.store_refresh_count_max = assert(user.store_refresh_count_max)	
					return ret
				end
			end
		else
			ret.errorcode = errorcode[6].code
			ret.msg	= errorcode[6].msg
			local j = assert(get_journal())
			ret.goods_refresh_count = assert(j.goods_refresh_count)
			ret.store_refresh_count_max = assert(user.store_refresh_count_max)	
			return ret
		end
	else
		assert(false)
	end
end

function REQUEST:recharge_all()
	-- body
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

function REQUEST:recharge_purchase()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(self.g)
	for i,v in ipairs(self.g) do
		local goods = skynet.call(game, "lua", "query_g_recharge", v.csv_id)
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
		local user_vip_max
		local ptr = skynet.call(game, "lua", "query_g_config")
		tptr.createtable(ptr)
		for _,k,v in tptr.pairs(ptr) do
			if k == "user_vip_max" then
				user_vip_max = v
				break
			end
		end
		assert(user_vip_max)
		repeat
			if user.uviplevel >= user_vip_max then
				break
			end
			local condition = skynet.call(game, "lua", "query_g_recharge_vip_reward", user.uviplevel + 1)
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
				user.uvip_progress = math.floor(progress * 100)
				user:__update_db({"uvip_progress"})
				break
			end
		until false
	end
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.u = {
		uname = user.uname,
    	uviplevel = user.uviplevel,
    	uexp = user.uexp,
    	config_sound = (user.config_sound == 1) and true or false,
    	config_music = (user.config_music == 1) and true or false,
    	avatar = user.avatar,
    	sign = user.sign,
    	c_role_id = user.c_role_id,
    	gold = user.u_propmgr:get_by_csv_id(const.GOLD).num,
    	diamond = user.u_propmgr:get_by_csv_id(const.DIAMOND).num,
    	recharge_total = user.recharge_rmb,
    	recharge_progress = user.uvip_progress,
    	recharge_diamond = user.recharge_diamond,
    	love = user.u_propmgr:get_by_csv_id(const.LOVE).num,
    	level = user.level
	}
	return ret
end

function REQUEST:recharge_vip_reward_all()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(user)
	local a = skynet.call(game, "lua", "query_g_recharge_vip_reward")
	local l = {}
	for k,v in pairs(a) do
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
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.reward = l
	return ret
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
			prop:__update_db({"num"})
		end
		local t = {user_id=user.csv_id, vip=self.vip, collected=1, purchased=0}	
		rc = user.u_recharge_vip_rewardmgr.create(t)
		user.u_recharge_vip_rewardmgr:add(rc)
		rc:__insert_db()
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
		if r < e.enhance_success_rate + (e.enhance_success_rate * user.equipment_enhance_success_rate_up_p) then
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
			e:__update_db({"level", "combat", "defense", "critical_hit", "king", "combat_probability", "defense_probability", "critical_hit_probability", "king_probability", "enhance_success_rate", "currency_type", "currency_num"})
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
			return ret
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

function REQUEST:role_all()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	local l = {}
	local r = skynet.call(game, "lua", "query_g_role")
	for k,v in pairs(r) do
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
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.l = l
	-- ret.combat = 
 --    ret.defense =
 --    ret.critical_hit =
 --    ret.blessing =
    return ret
end

function REQUEST:role_recruit()
	-- body
	local ret = {}
	if not ret then
		ret.errorcode = errorcode[2].code
		ret.msg = errorcode[2].msg
		return ret
	end
	assert(self.csv_id)
	assert(user.u_rolemgr:get_by_csv_id(self.csv_id) == nil)
	local role = skynet.call(game, "lua", "query_g_role", self.csv_id)
	local us = skynet.call(game, "lua", "query_g_role_star", role.csv_id*1000 + role.star)
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
	user:__update_db({"sign"})
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
 					prop:__insert_db()
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
				prop:__insert_db()
				table.insert(l, { csv_id=prop.csv_id, num=prop.num})
 			end
 		end
 		local t = { user_id=user.csv_id, vip=self.vip, collected=0, purchased=1}
 		rc = user.u_recharge_vip_rewardmgr.create(t)
 		user.u_recharge_vip_rewardmgr:add(rc)
 		rc:__insert_db()
 		ret.errorcode = errorcode[1].code
 		ret.msg = errorcode[1].msg
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
	skynet.error(string.format("request: %s", name))
    local f = nil
    if REQUEST[name] ~= nil then
    	f = assert(REQUEST[name])
    elseif nil ~= friendrequest[ name ] then
    	f = assert( friendrequest[ name ] )
    else
    	for i,v in ipairs(M) do
    		if v.REQUEST[name] ~= nil then
    			f = v.REQUEST[name]
    			break
    		end
    	end
    end
    assert(f)
    assert(response)
    local ok, result = pcall(f, args)
    if not ok then
    	skynet.error(result)
		local ret = {
			errorcode = errorcode[29].code,
			msg = errorcode[29].msg
		}
		return response(ret)
    else
	    if name == "login" then
	    	if result.errorcode == errorcode[1].code then
	    		for k,v in pairs(M) do
	    			if v.REQUEST then
	    				v.REQUEST[name](v.REQUEST, user)
	    			end
	    		end
	    	end
	    end
	    return response(result)
    end
end      

function RESPONSE:finish_achi( ... )
	-- body
	assert(self.errorcode == 1)
	skynet.error(self.msg)
end

local function response(name, args)
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

	-- local ptr = skynet.call(game, "lua", "ptr")
	-- tptr.createtable(ptr)
	-- G = ptr
	-- for _,k,v in tptr.pairs(G) do
	-- 	print(k, v)
	-- 	-- tptr.createtable(v)
	-- 	-- assert(v.__data ~= "table")
	-- 	-- ptr = tptr.topointer(v)
	-- 	-- tptr.createtable(ptr)
	-- 	-- for _,k,v in tptr.pairs(ptr) do
	-- 	-- 	print(k,v)
	-- 	-- end
	-- end

	local t = loader.load_game()
	for i,v in ipairs(M) do
		v.start(fd, send_request, t)
	end
	
end	
	   
function CMD.disconnect()
	-- todo: do something before exit
	local str = string.format("client %d disconnect, ", client_fd)
	flush_db()
	if user then
		str = str .. str.format("user %d will quit", user.csv_id)
		user.ifonline = 0
		user:__update_db({"ifonline"})
		dc.set( user.csv_id , nil )
	else
		str = str .. "user has quit."
	end
	skynet.error(str)
	skynet.exit()
end	

function CMD.friend( subcmd, ... )
	-- body
	local f = assert(friendrequest[subcmd])
	local r =  f(friendrequest, ...)
	if r then
		return r
	end
end

function CMD.newemail( subcmd , ... )
	local f = assert( new_emailrequest[ subcmd ] )
	f( new_emailrequest , ... )
end

local function update_db()
	-- body
	while true do
		flush_db()
		skynet.sleep(100 * 60) -- 1ti == 0.01s
	end
end

skynet.init(function ()
	-- body
	game = skynet.uniqueservice("game")
end)

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		print("agent is called" , command)
		local f = CMD[command]
		local result = f( ... )
		if result then
			skynet.ret(skynet.pack(result))
		end
	end)
	skynet.fork(update_db)
end)
