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

--local emailrequest = require "emailrequest"
--local emailbox = require "emailbox"
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

table.insert( M , checkinrequest )
table.insert( M , exercise_request )
table.insert( M , cgold_request )
table.insert( M , new_emailrequest )

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
local level_limit
local wakeattr
local wakecost
	  
local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

local function convert_level( t )
	-- body
	local r = {}
	for i,v in ipairs(t) do
		r[tostring(v.level)] = v
	end
	return r
end

local function convert_wakecost( t )
	-- body
	local r = {}
	for i,v in ipairs(t) do
		r[tostring(v.id)] = v
	end
	return r
end

local function id(__wake, __level)
	-- body
	return __wake * 1000 + __level	
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
			local r = user.u_achievementmgr:get_by_type(const.A_T_GOLD)
			local a = r[1]
			assert(a) -- must be only one
			if a.is_valid == 0 then
				break
			end
			local gold = user.u_propmgr:get_by_csv_id(const.GOLD) -- abain prop by type (type -- csv_id -- prop.id)		
			local progress = gold.num / a.c_num
			print("***********************************ccbc", gold.num, a.c_num, progress)
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
					
					local ga2 = game.g_achievementmgr:get_by_csv_id(k1)
					local t = ga2:__serialize()
					t.user_id = user.id
					t.finished = 100
					t.is_unlock = 1
					t.reward_collected = 0
					local a1 = user.u_achievement_rcmgr.create(t)
					user.u_achievement_rcmgr:add(a1)
					a1:__insert_db()

					if tonumber(k2) == 0 then
						a.is_valid = 0
						a:__update_db({"is_valid"})	
						break
					else
						local ga = game.g_achievementmgr:get_by_csv_id(k2)
						assert(ga)
						a.csv_id = ga.csv_id
						a.finished = 0
						a.c_num = ga.c_num
						a.unlock_next_csv_id = ga.unlock_next_csv_id
						-- a.is_unlock = 1
						a:__update_db({"csv_id", "finished", "c_num", "unlock_next_csv_id", "is_valid"})	
					end
				else
					local ga = game.g_achievementmgr:get_by_csv_id(a.unlock_next_csv_id)
					assert(ga)
					a.csv_id = ga.csv_id
					a.finished = 0
					a.c_num = ga.c_num
					a.unlock_next_csv_id = ga.unlock_next_csv_id
					a.is_unlock = 1
					a:__update_db({"csv_id", "finished", "c_num", "unlock_next_csv_id"})	
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
			local r = user.u_achievementmgr:get_by_type(type)
			local a = assert(r[1])
			local exp = user.u_propmgr:get_by_csv_id(const.EXP) -- abain prop by type (type -- csv_id -- prop.id)		
			local progress = exp.num / a.c_num
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
					print("*******jflda", a.unlock_next_csv_id, k1, k2)
					
					local ga2 = game.g_achievementmgr:get_by_csv_id(k1)
					local t = ga2:__serialize()
					t.user_id = user.id
					t.finished = 100
					t.is_unlock = 1
					t.reward_collected = 0
					local a1 = user.u_achievement_rcmgr.create(t)
					user.u_achievement_rcmgr:add(a1)
					a1:__insert_db()

					if tonumber(k2) == 0 then
						a.is_valid = 0
						a:__update_db({"is_valid"})	
						break
					else
						local ga = game.g_achievementmgr:get_by_csv_id(k2)
						assert(ga)
						a.csv_id = ga.csv_id
						a.finished = 0
						a.c_num = ga.c_num
						a.unlock_next_csv_id = ga.unlock_next_csv_id
						-- a.is_unlock = 1
						a:__update_db({"csv_id", "finished", "c_num", "unlock_next_csv_id", "is_valid"})	
					end

				else
					local ga = game.g_achievementmgr:get_by_csv_id(a.unlock_next_csv_id)
					assert(ga)
					a.csv_id = ga.csv_id
					a.finished = 0
					a.c_num = ga.c_num
					a.unlock_next_csv_id = ga.unlock_next_csv_id
					a.is_unlock = 1
					a:__update_db({"csv_id", "finished", "c_num", "unlock_next_csv_id"})	
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

local function subscribe()
	-- body
	local c = skynet.call(".channel", "lua", "agent_start", user.id, skynet.self())
	local c2 = mc.new {
		channel = c,
		dispatch = function ( channel, source, cmd, tvals , ... )
			-- body
			local f = assert(SUBSCRIBE[cmd])
			f(tvals, ...)
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
	local function achievement_r(v, a)
		-- body
		local rc2 = user.u_achievementmgr:get_by_type(v.type)
		if rc2 and #rc2 >= 1 then
			if rc2[1].is_valid == 1 then
				if rc2[1].c_num > v.c_num then
					local rc1 = user.u_achievement_rcmgr:get_by_csv_id(v.csv_id)
					assert(rc1)
					a.finished = rc1.finished
					a.reward_collected = (rc1.reward_collected == 1) and true or false
					a.is_unlock = (rc1.is_unlock == 1) and true or false
				elseif rc2[1].csv_id == v.csv_id then
					a.finished = rc2[1].finished
					a.reward_collected = false
					a.is_unlock = (rc2[1].is_unlock == 1) and true or false
				else
					a.finished = 0
					a.reward_collected = false
					a.is_unlock = false
				end
			elseif rc2[1].is_valid == 0 and rc2[1].type == v.type then
				local rc1 = user.u_achievement_rcmgr:get_by_csv_id(v.csv_id)
				assert(rc1)
				a.finished = rc1.finished
				a.reward_collected = (rc1.reward_collected == 1) and true or false
				a.is_unlock = (rc1.is_unlock == 1) and true or false
			else
				a = nil
			end
		else
			if v.is_init == 1 then
				local t = v:__serialize()
				t.user_id = user.id
				t.finished = 0         -- [0, 100]
				t.reward_collected = 0
				t.is_unlock = 1
				t.is_valid = 1
				local achievement = user.u_achievementmgr.create(t)
				user.u_achievementmgr:add(achievement)
				achievement:__insert_db()
					-- raise_achievement(v.type, user, game)
					-- fix achievement value
				a.finished = 0
				a.reward_collected = false
				a.is_unlock = true
			end
		end
		return a
	end
	local l = {}
	local idx = 1
	for k,v in pairs(game.g_achievementmgr.__data) do
		local a = {}
		a.csv_id = v.csv_id
		achievement_r(v, a)
		if a then
			l[idx] = a
			idx	= idx + 1
		end
	end
	ret.errorcode = 0
    ret.msg = "this is all achievement."
    ret.achis = l
    return ret
end

function REQUEST:achievement_reward_collect()
	-- body
	-- 1 not online
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "not online"
		return ret
	end
	assert(user)
	assert(self.csv_id)
	local a = user.u_achievement_rcmgr:get_by_csv_id(self.csv_id)
	print(self.csv_id)
	for k,v in pairs(a) do
		print(k,v)
	end
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
				prop.user_id = user.id
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

function REQUEST:role()
	print "************************role"
	print(user.c_role_id)
	local role = rolemgr:find(user.c_role_id)
	local ret = {
		errorcode = 0,
		msg = "",
		id = role.id,
		wake_level = role.wake_level,
		level = role.level,
		combat = role.combat,
		defense = role.defense,
		critical_hit = role.critical_hit,
		skill = role.skill,
		c_equipment = role.c_equipment,
		c_dress = role.c_dress,
		c_kungfu = role.c_kungfu
	}
	return ret
end	
    
function REQUEST:signup()
	-- body
	print( "*****************************signup is called" )
	local ret = {}
	local condition = { uaccount = self.account}
	local addr = util.random_db()
	local r = skynet.call(addr, "lua", "command", "signup", { condition } )
	if #r == 0 then
		local t = { csv_id=util.guid(game, const.UENTROPY), 
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
				level=0, 
				combat=0, 
				defense=0, 
				critical_hit=0, 
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
				cgold_level=0 }
		local usersmgr = require "models/usersmgr"
		local u = usersmgr.create(t)
		u:__insert_db()

		local u_equipmentmgr = require "models/u_equipmentmgr"
		local e1 = game.g_equipmentmgr:get_by_csv_id(1001)
		e1.user_id = u.csv_id
		local ue1 = u_equipmentmgr.create(e1)
		ue1:__insert_db()

		local e2 = game.g_equipmentmgr:get_by_csv_id(2001)
		e2.user_id = u.csv_id
		local ue2 = u_equipmentmgr.create(e2)
		ue2:__insert_db()

		local e3 = game.g_equipmentmgr:get_by_csv_id(3001)
		e3.user_id = u.csv_id
		local ue3 = u_equipmentmgr.create(e3)
		ue3:__insert_db()

		local e4 = game.g_equipmentmgr:get_by_csv_id(4001)
		e4.user_id = u.csv_id
		local ue4 = u_equipmentmgr.create(e4)
		ue4:__insert_db()		

		local u_propmgr = require "models/u_propmgr"
		local gold = u_propmgr.create_gold(u, 100)
		gold:__insert_db()

		local diamond = u_propmgr.create_diamond(u, 10)
		diamond:__insert_db()

		local u_kungfumgr = require "models/u_kungfumgr"
		local kungfu = game.g_kungfumgr:get_by_csv_id(1001)
		kungfu.user_id = assert(u.csv_id)
		kungfu.is_learned = 0
		local k = u_kungfumgr.create(kungfu)
		k:__insert_db()

		ret.errorcode = 0
		ret.msg	= "yes"
		return ret
	else
		ret.errorcode = 1
		ret.msg = "yes, have "
		return ret
	end
end 
    
function REQUEST:login()
	local ret = {}
	if user then
		ret.errorcode = 1
		ret.msg	= "on"
		return ret
	end
	assert(self.account and	self.password)
	assert(#self.password > 1)
	local condition = { uaccount = self.account, upassword = self.password }
	local addr = util.random_db()
	local r = skynet.call(addr, "lua", "command", "select", "users", { condition } )
    
	if #r == 0  then
		print("***************************afa", #r)
		ret.errorcode = 1 -- 1 user hasn't register.
		ret.msg = "no"
		return ret
	else
		local usersmgr = require "models/usersmgr"
		user = usersmgr.create(r[1])
		loader.load_user(user)
		subscribe()
		skynet.fork(subscribe)

		ret.errorcode = 0
		ret.msg = "yes"
		ret.u = {
			uname = user.uname,
			uviplevel = user.uviplevel,
			config_sound = user.config_sound and true or false,
			config_music = user.config_music and true or false,
			avatar = user.avatar,
			sign = user.sign,
			c_role_id = user.c_role_id,
		}
		if user.u_propmgr:get_by_csv_id(const.EXP) then
			ret.u.uexp = user.u_propmgr:get_by_csv_id(const.EXP).num
		end
		if user.u_propmgr:get_by_csv_id(const.GOLD) then
			ret.u.gold = user.u_propmgr:get_by_csv_id(const.GOLD).num
		end
		if user.u_propmgr:get_by_csv_id(const.DIAMOND) then
			ret.u.diamond = user.u_propmgr:get_by_csv_id(const.DIAMOND).num
		end
		-- all roles
		local l = {}
		local idx = 1
		for k,v in pairs(user.u_rolemgr.__data) do
			local r = {
				role_id = v.id,
				wake_level = v.wake_level,
				level = v.level,
				combat = v.combat,
				defense = v.defense,
				critical_hit = v.critical_hit,
				skill = v.skill,
				c_equipment = v.c_equipment,
				c_dress = v.c_dress,
				c_kungfu = v.c_kungfu
			}
			l[idx] = r
		end
		ret.rolelist = l
	end 
	print( "dc is  *******************************************************" )
	print( user.id , client_fd , skynet.self() )
	dc.set(user.id, { client_fd=client_fd, addr=skynet.self()})
	print( "dc is called *******************************************************" )
	local onlinetime = os.time()
	user.ifonline = 1
	user.onlinetime = onlinetime
	user:__update_db({"ifonline", "onlinetime"})

	--user.emailbox = emailbox:loademails( user.id )
	--emailrequest.getvalue( user )
	user.friendmgr = friendmgr:loadfriend( user , dc )
	friendrequest.getvalue( user , send_package , send_request )
	user.drawmgr = drawmgr
	drawrequest.getvalue( user , game )
	--user.friendmgr:noticeonline( dc )
	return ret
end	

function REQUEST:logout()
	-- body
	assert(user)
	user.ifonline = 0
	user:__update_db({"ifonline"})
	dc.set( user.id , nil )
	-- send chanel 
	-- skynet.send()
	user = nil
	return { errorcode = 0 }
end

function REQUEST:role()
	assert(user)
	assert(self.role_id)
	print(self.role_id)
	print(user.id)
	for k,v in pairs(user.u_rolemgr.__data) do
		print(k,v)
	end
	local role = user.u_rolemgr:get_by_csv_id(self.role_id)
	for k,v in pairs(role) do
		print(k,v)
	end
	local ret = {
		errorcode = 0,
		msg = "",
		r = {
			id = role.csv_id,
			wake_level = role.wake_level,
			level = role.level,
			combat = role.combat,
			defense = role.defense,
			critical_hit = role.critical_hit,
			skill = role.skill,
			c_equipment = role.c_equipment,
			c_dress = role.c_dress,
			c_kungfu = role.c_kungfu
		}
	}
	return ret
end	

function REQUEST:choose_role()
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
	assert(user)
	print(self.role_csv_id, user.c_role_id)
	-- assert(self.role_csv_id == user.c_role_id)
	local ret = {}
	local role = user.u_rolemgr:get_by_csv_id(self.role_csv_id)
	local role_pieces_csv_id = 1
	local prop = user.u_propmgr:get_by_csv_id(self.role_id)
	if prop.num > role.star_piece then
		role.star_level = role.star_level + 1
		skynet.send(util.random_db(), "lua", "command", "update", "roles", {{ id = role.id }}, { star_level = role.star_level })
		-- return
		ret.errorcode = 0
		ret.msg = "yes"
		ret.r = {
			id = role.id,
			wake_level = role.wake_level,
			level = role.level,
			combat = role.combat,
			defense = role.defense,
			critical_hit = role.critical_hit,
			skill = role.skill,
			c_equipment = role.c_equipment,
			c_dress = role.c_dress,
			c_kungfu = role.c_kungfu,
			star_level = role.star_level
		}
		return ret
	else
		ret.errorcode = 1
		ret.msg = "not enough exp."
		return ret
	end
end		
		
function REQUEST:wake()
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
	-- 1 not online
	-- 2 not enough
	-- 3 no exit 0 make use
	local ret = {}
	if not user then
		ret.errorcode = 1 
		ret.msg = "not online"
		return ret
	end
	assert(user)
	assert(#self.props >= 1)
	local l = {}
	local idx = 1
	for k,v in pairs(self.props) do
		local prop = user.u_propmgr:get_by_csv_id(v.csv_id)
		if v.num > 0 then
			-- get
			prop.num = prop.num + self.props[1].num
			prop.__update_db({"num"})
			l[idx] = {csv_id=prop.csv_id, num=prop.num}
			idx = idx + 1
		else
			-- consume
			if prop.num < math.abs(v.num) then
				ret.errorcode = 2
				ret.msg = "not enough prop."
				return ret
			end
			if prop.use_type == 0 then
				ret.errorcode = 3
				ret.msg = "don't use"
				return ret
			end
			prop.num = prop.num + v.num
			prop:__update_db({"num"})
			if assert(prop.use_type) == 1 then -- exp 
				local e = user.u_propmgr:get_by_csv_id(const.EXP)
				e.num = e.num + tonumber(prop.pram1)
				e:__update_db({"num"})
				raise_achievement(const.A_T_EXP, user, game)
			elseif assert(prop.use_type) == 2 then -- gold
				local g = user.u_propmgr:get_by_csv_id(const.GOLD)
				g.num = g.num + tonumber(prop.pram1)
				g:__update_db({"num"})
				raise_achievement(const.A_T_GOLD, user, game)
			elseif assert(prop.use_type) == 3 then
				local csv_id1 = string.gsub(prop.pram1, "(%d*)%*(%d*)%*(%d*)%*(%d*)", "%1")
				local num1 = string.gsub(prop.pram1, "(%d*)%*(%d*)%*(%d*)%*(%d*)", "%2")
				local p1 = user.u_propmgr:get_by_csv_id(csv_id1)
				p1.num = p1.num + num1 * math.abs(v.num)
				p1:__update_db({"num"})
				if csv_id1 == const.GOLD then
					raise_achievement(const.A_T_GOLD, user, game)
				elseif csv_id1 == const.EXP then
					raise_achievement(const.A_T_EXP, user, game)
				end
				local csv_id2 = string.gsub(prop.pram1, "(%d*)%*(%d*)%*(%d*)%*(%d*)", "%3")
				local num2 = string.gsub(prop.pram1, "(%d*)%*(%d*)%*(%d*)%*(%d*)", "%4")
				local p2 = user.u_propmgr:get_by_csv_id(csv_id2)
				p2.num = p2.num + num1 * math.abs(v.num)
				p2:__update_db({"num"})
				if csv_id2 == const.GOLD then
					raise_achievement(const.A_T_GOLD, user, game)
				elseif csv_id2 == const.EXP then
					raise_achievement(const.A_T_EXP, user, game)
				end
			elseif assert(prop.use_type) == 4 then
				local csv_id1 = string.gsub(prop.pram1, "(%d*)%*(%d*)%*(%d*)%*(%d*)%*(%d*)%*(%d*)", "%1")
				local num1 = string.gsub(prop.pram1, "(%d*)%*(%d*)%*(%d*)%*(%d*)%*(%d*)%*(%d*)", "%2")
				local pro1 = string.gsub(prop.pram1, "(%d*)%*(%d*)%*(%d*)%*(%d*)%*(%d*)%*(%d*)", "%3")
				local csv_id2 = string.gsub(prop.pram1, "(%d*)%*(%d*)%*(%d*)%*(%d*)%*(%d*)%*(%d*)", "%4")
				local num2 = string.gsub(prop.pram1, "(%d*)%*(%d*)%*(%d*)%*(%d*)%*(%d*)%*(%d*)", "%5")
				local pro2 = string.gsub(prop.pram1, "(%d*)%*(%d*)%*(%d*)%*(%d*)%*(%d*)%*(%d*)", "%6")
				local n = tonumber(pro1) + tonumber(pro2)
				if math.random(1, n) < tonumber(pro1) then
					local p1 = user.u_propmgr:get_by_csv_id(csv_id1)
					if p1 then
						p1.num = p1.num + tonumber(num1) * math.abs(v.num)
						p1:__update_db({"num"})
					else
						local p = game.g_propmgr:get_by_csv_id(csv_id1)
						p.user_id = user.id
						p.num = tonumber(num1) * math.abs(v.num)
						p:__insert_db()
					end
				else
					local p2 = user.u_propmgr:get_by_csv_id(csv_id2)
					if p2 then
						p2.num = p2.num + tonumber(num1) * math.abs(v.num)
						p2:__update_db({"num"})
					else
						local p = game.g_propmgr:get_by_csv_id(csv_id2)
						p.user_id = user.id
						p.num = tonumber(num2) * math.abs(v.num)
						p:__insert_db()
					end
				end
			end	
			l[idx] = {csv_id=prop.csv_id, num=prop.num}
			idx = idx + 1
		end
	end
	ret.errorcode = 0
	ret.msg	= "yes"
	ret.props = l
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
	local u_propmgr = user.u_propmgr
	local exp = u_propmgr:get_by_csv_id(const.EXP)
	if exp then
		ret.user.uexp = exp.num
	end
	local gold = u_propmgr:get_by_csv_id(const.GOLD)
	if gold then
		ret.user.gold = gold.num
	end
	local diamond = u_propmgr:get_by_csv_id(const.DIAMOND)
	if diamond then
		ret.user.diamond = diamond.num
	end
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
		return msg
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
	assert(user)
	local ret = {}
	print(user.level)
	local L = level_limit[tostring(user.level)]
	local exp = user.u_propmgr:get_by_csv_id(const.EXP).num
	if exp > tonumber(L.exp) then
		add_achievement()
		user.level = user.level + 1
		local LL = level_limit[tostring(user.level)]
		user.combat = LL.combat
		user.critical_hit = LL.critical_hit
		user:__update_db({ "combat", "critical_hit"})
		ret.errorcode = 0
		ret.msg = "yes"
		return ret
	else
		ret.errorcode = 1
		ret.msg	= string.format("no enough exp:%d, need:%d", exp, L.exp)
		return ret
	end
end

function REQUEST:shop_all()
	-- body
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
	ret.msg = "yes"
	ret.l = ll
	return ret
end

function REQUEST:shop_refresh()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "not online."
		return ret
	end
	assert(user)
	local hour = os.date("%H")
	local min = os.date("%M")
	local sec = os.date("%S")
	if tonumber(hour) > config.goods_refresh_reset_h then
		user.goods_refresh_count = 0
	end
	local rc = game.g_goods_refresh_costmgr:get_by_csv_id(user.goods_refresh_count)
	local p = user.u_propmgr:get_by_csv_id(rc.currency_type)
	if p.num > rc.currency_num then
		p.num = p.num - rc.currency_num
		p:__update_db({"num"})
		ret.errorcode = 0
		ret.msg = "yes"
		local v = game.g_goodsmgr:get_by_csv_id(self.goods_id)
		local g = {
			csv_id = v.csv_id,
			currency_type = v.currency_type,
			currency_num = v.currency_num,
			g_prop_csv_id = v.g_prop_csv_id,
			g_prop_num = v.g_prop_num,
			inventory = v.inventory_init,
			countdown = v.cd
		}
		local ll = {g}
		ret.l = ll
		return ret
	end
	user.goods_refresh_count = user.goods_refresh_count + 1
	user:__update_db({"goods_refresh_count"})
	ret.errorcode = 2
	ret.msg = "not enough diamond."
	return ret
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
	for k,v in pairs(l) do
		local goods = v
		if goods.inventory == 0 then
			ret.errorcode = 2
			ret.msg = "no enough goods"
			return ret
		end
		if goods.currency_type == const.GOLD then
			local gold = goods.currency_num * goods.p_num
			-- gold 2
			local currency = user.u_propmgr:get_by_csv_id(const.GOLD)
			if currency.num > gold then
				print("******************abc", goods.inventory)
				if goods.inventory == 99 then
				elseif goods.inventory > goods.p_num then
					local g = game.g_goodsmgr:get_by_csv_id(goods.csv_id)
					g.inventory = g.inventory - goods.p_num
					g:__update_db({"inventory"})
				else
					ret.errorcode = 5
					ret.msg = "not inventory"
					return ret
				end
				currency.num = currency.num - gold
				currency:__update_db({"num"})
				local prop = user.u_propmgr:get_by_csvid(goods.g_prop_csv_id)
				if prop then
					prop.num = prop.num + goods.g_prop_num * goods.p_num
					prop:__update_db({"num"})
				else
					local p = game.g_propmgr:get_by_csv_id(goods.g_prop_csv_id)
					p.user_id = user.id
					p.num = goods.g_prop_num * goods.p_num
					local prop = user.u_propmgr.create(p)
					user.u_propmgr:add(prop)
					prop:__insert_db()
				end
				local t = { user_id=user.id, csv_id=goods.id, num=goods.p_num, currency_type=const.GOLD, currency_num=gold, purchase_time=os.time()}
				local rc = user.u_purchase_goodsmgr.create(t)
				user.u_purchase_goodsmgr:add(rc)
				rc:__insert_db()
				ret.errorcode = 0
				ret.msg	= "yes, take gold"
				return ret
			else
				ret.errorcode = 3
				ret.msg	= string.format("yes, no enough gold, only %d", goods.gold)
				return ret
			end
		elseif goods.currency_type == const.DIAMOND then
			local diamond = goods.currency_num * goods.p_num
			local currency = user.u_propmgr:get_by_csv_id(const.DIAMOND)
			if currency.num > diamond then
				print("******************abc", goods.inventory)
				if goods.inventory == 99 then
				elseif goods.inventory > goods.p_num then
					local g = game.g_goodsmgr:get_by_csv_id(goods.csv_id)
					g.inventory = g.inventory - goods.p_num
					g:__update_db({"inventory"})
				else
					ret.errorcode = 5
					ret.msg = "not inventory"
					return ret
				end
				currency.num = currency.num - diamond
				currency:__update_db({"num"})
				local prop = user.u_propmgr:get_by_csv_id(goods.g_prop_csv_id)
				if prop then
					prop.num = prop.num + goods.g_prop_num * goods.p_num
					prop:__update_db({"num"})
				else	
					prop = game.g_propmgr:get_by_csv_id(assert(goods.g_prop_csv_id))
					prop.user_id = user.id
					prop.num = goods.g_prop_num * goods.p_num
					prop = user.u_propmgr.create(prop)
					user.u_propmgr:add(prop)
					prop:__insert_db()
				end
				local t = { user_id=user.id, csv_id=goods.csv_id, num=goods.p_num, currency_type=const.DIAMOND, currency_num=diamond, purchase_time=os.time()}
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
	-- 1 not online
	-- 2 
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "no"
		return ret
	end
	ret.errorcode = 0
	ret.msg = "yes"
	ret.l = skynet.call(".shop", "lua", "recharge_all")
	return ret
end

function REQUEST:recharge_vip_reward_all()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "no"
		return ret
	end
	assert(user)
	local l = {}
	for k,v in pairs(game.g_recharge_vip_rewardmgr.__data) do
		local r = {}
		r.vip = v.vip
		r.props = {{csv_id=const.DIAMOND, num=v.diamond}}
		r.collected = user.u_recharge_vip_rewardmgr:get_by_vip(v.vip) and true or false
		table.insert(l, r)
	end
	ret.errorcode = 0
	ret.msg = "yes"
	ret.reward = l
	return ret
end

function REQUEST:recharge_vip_reward_collect()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "not online"
		return ret
	end
	if self.vip == 0 then
		ret.errorcode = 2
		ret.msg = "no reward"
		return ret
	end
	if self.vip > user.uviplevel then
		ret.errorcode = 3
		ret.msg = "error"
		return ret
	end
	assert(user)
	local rc = user.u_recharge_vip_rewardmgr:get_by_vip(self.vip)
	if rc and rc.collected then
		ret.errorcode = 2
		ret.msg = "you have collected."
		return ret
	end
	local t = {user_id=user.id, vip=self.vip, collected=1}
	rc = user.u_recharge_vip_rewardmgr.create(t)
	rc:__insert_db()
	ret.errorcode = 0
	ret.msg = "yes"
	ret.vip = user.uviplevel
	ret.collected = true
	return ret
end

function REQUEST:recharge_purchase()
	-- body
	-- 1 not online
	-- 2 no exit
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "not online"
		return ret
	end
	local l = {}
	local idx = 1
	print(type(self.g))
	for i,v in ipairs(self.g) do
		print(v.csv_id)
		local r = game.g_rechargemgr:get_by_csv_id(v.csv_id)
		local goods = r:__serialize()
		goods.p_num = v.num
		l[idx] = goods
		idx = idx + 1
	end
	local r = l
	if #r == 0 then
		ret.errorcode = 2
		ret.msg = "no exist"
		return ret
	end
	for i,v in ipairs(r) do
		user.recharge_rmb = user.recharge_rmb + v.rmb * v.p_num
		user.recharge_diamond = user.recharge_diamond + v.diamond * v.p_num
		local rc = user.u_recharge_countmgr:get_by_csv_id(v.csv_id)
		if rc then
			rc.count = rc.count + 1
			if rc.count > 1 then
				rc:__update_db({"count"})
				local diamond = user.u_propmgr:get_by_csv_id(const.DIAMOND)
				diamond.num = diamond.num + (v.diamond + v.gift) * v.p_num
				diamond:__update_db({"num"})
			else
				assert(false)
			end
		else
			rc = user.u_recharge_countmgr.create({user_id=user.id, csv_id=v.csv_id, count=1})
			rc:__insert_db()
			local diamond = user.u_propmgr:get_by_csv_id(const.DIAMOND)
			diamond.num = diamond.num + (v.diamond + v.gift) * v.p_num
			diamond:__update_db({"num"})
		end
		local t = {user_id=user.id, csv_id=v.csv_id, num=v.p_num, dt=os.time()}
		rc = user.u_recharge_recordmgr.create(t)
		user.u_recharge_recordmgr:add(rc)
		rc:__insert_db()

		-----------------------------
		repeat
			if user.uviplevel + 1 >= 6 then
				break
			end
			local vip = game.g_recharge_vip_rewardmgr:get_by_vip(user.uviplevel + 1)
			if not vip then
				error "don't upgrade, no data."
			end
			local progress = user.recharge_diamond / vip.diamond
			if progress >= 1 then
				user.uviplevel = user.uviplevel + 1
				user:__update_db({"uviplevel"})
			else
				user.uvip_progress = progress * 100
				user:__update_db({"uvip_progress"})
				break
			end
		until false
		user:__update_db({"recharge_rmb", "recharge_diamond"})
	end
	ret.errorcode = 0
	ret.msg = "yes"
	return ret
end

function REQUEST:recharge_reward()
	local ret = {}
	ret.errorcode = 0
	ret.msg	= "yes"
	local l = {}
	local idx = 1
	for k,v in pairs(user.u_recharge_reward.__data) do
		local reward = {}
		reward["id"] = v.id
		reward.distribute_dt = v.distribute_dt
		reward.icon_id = v.icon_id
		l[idx] = l
 	end
 	ret.l = l
 	return ret
end

function REQUEST:recharge_collect()
	-- body
	print(os.date())
	local year = os.date("%Y")
	local month = os.date("%m")
	local day = os.date("%d")
	local hour = os.date("%H")
	local min = os.date("%M")
	local sec = os.date("%S")
	
	local condition = string.format("distribute_time between \"%d-%d-%d 00:00:00\" and \"%s\"", year, month, day, os.date("%Y-%m-%d %H:%M:%S"))
	local r = skynet.call(util.random_db(), "lua", "command", "select", "u_recharge_reward", condition)
	print(#r)
	for i,v in ipairs(r) do
		if v.collected == 0 then
			local prop = user.propmgr:get_by_csvid(v.prop_csv_id)
			if prop then
				prop.num = prop.num + v.prop_num
				skynet.send(util.random_db(), "lua", "command", "update_prop", prop.user_id, prop.csv_id, prop.num)
				skynet.send(util.random_db(), "lua", "command", "update", "u_purchase_reward", {{ id = v.id }}, { collected = 1})
			else
				local t = { user_id = user.id, csv_id = v.prop_csv_id, num = v.prop_num}
				local prop = user.propmgr.create(t)
				skynet.send(util.random_db(), "lua", "command", "insert", "props", t)
			end
			local ret = {}
			ret.errorcode = 0
			ret.msg = "yes"
			return ret
		end
	end
	local ret = {}
	ret.errorcode = 1
	ret.msg = "no exist"
	return ret
end

function REQUEST:equipment_enhance()
	-- body
	-- 1 offline
	-- 2 don't have enough money.
	-- 3 rate
	local ret = {}
	if not user then
		ret.errorcode = 1
		ret.msg = "offline."
		return ret
	end
	for k,v in pairs(user.u_equipmentmgr.__data) do
		print(k,v)
	end
	local e = user.u_equipmentmgr:get_by_csv_id(self.csv_id)
	if e.type == 1 then
		local last = user.u_equipmentmgr:get_by_type(4)
		assert(e.level <= last.level)
	else
		local last = user.u_equipmentmgr:get_by_type(e.type - 1)
		assert(e.level <= last.level)
	end
	local currency = user.u_propmgr:get_by_csv_id(e.currency_type)
	if currency.num < e.currency_num then
		ret.errorcode = 2
		ret.msg = "don't have enough money."
	else
		local r = math.random(0, 100)
		if r < e.enhance_success_rate then
			currency.num = currency.num - e.currency_num
			currency:__update_db({"num"})
			local id = (e.level + 1) + 1000 * e.type
			local ge = game.g_equipmentmgr:get_by_csv_id(id)
			e.level = ge.level
			e.combat = ge.combat
			e.defense = ge.defense
			e.critical_hit = ge.critical_hit
			e.king = ge.king
			e.critical_hit_probability = ge.critical_hit_probability
			e.defense_probability = ge.defense_probability
			e.king_probability = ge.king_probability
			e.enhance_success_rate = ge.enhance_success_rate
			e.currency_type = ge.currency_type
			e.currency_num = ge.currency_num
			e:__update_db({"level", "combat", "defense", "critical_hit_probability", "defense_probability", "king_probability", "enhance_success_rate", "currency_type", "currency_num"})
			ret.errorcode = 0
			ret.msg = "yes"
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
		print(k, v)
		local e = {
			csv_id = v.csv_id,
			type = v.type,
			level = v.level
		}
		table.insert(l, e)
	end
	ret.errorcode = 0
	ret.msg = "yes"
	ret.l = l
	return ret
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
    elseif nil ~= drawrequest[ name ] then
    	f = assert( drawrequest[ name ] )
    else
    	for i,v in ipairs(M) do
    		if v.REQUEST[name] ~= nil then
    			f = v.REQUEST[name]
    			break
    		end
    	end
    end
    print("*___________________________*", name) 
    assert(f)
    local r = f(args)
    if name == "login" then
    	for k,v in pairs(M) do
    		if v.REQUEST then
    			v.REQUEST[name](v.REQUEST, user)
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
