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

local emailrequest = require "emailrequest"
local emailbox = require "emailbox"
local friendrequest = require "friendrequest"
local friendmgr = require "friendmgr"
local drawrequest = require "drawrequest"
local drawmgr = require "drawmgr"
local csvReader = require "csvReader"
local const = require "const"
local config = require "config"

local M = {}

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
			local a = user.u_achievementmgr:get_by_type(const.A_T_GOLD)
			assert(a) -- must be only one
			local gold = user.u_propmgr:get_by_csv_id(const.GOLD) -- abain prop by type (type -- csv_id -- prop.id)		
			local progress = gold.num / a.c_num
			print("***********************************ccbc", gold.num, a.c_num, progress)
			if progress >= 1 then -- success
				a.finished = 100
				a.reward_collected = 0
				push_achievement(a)
				
				-- insert achievement rc	
				local rc = user.u_achievement_rcmgr.create(a)
				rc:__insert_db()

				if string.match(a.unlock_next_csv_id, "%d*%*%d*") then
					local k1 = string.gsub(a.unlock_next_csv_id, "(%d*)%*(%d*)", "%1")
					local k2 = string.gsub(a.unlock_next_csv_id, "(%d*)%*(%d*)", "%2")
					print("*******jflda", a.unlock_next_csv_id, k1, k2)
					local ga = game.g_achievementmgr:get_by_csv_id(k2)
					assert(ga)
					a.csv_id = ga.csv_id
					a.finished = 0
					a.c_num = ga.c_num
					a.unlock_next_csv_id = ga.unlock_next_csv_id
					a.is_unlock = 1
					a:__update_db({"csv_id", "finished", "c_num", "unlock_next_csv_id"})	

					local ga2 = game.g_achievementmgr:get_by_csv_id(k1)
					local t = ga2:__serialize()
					t.user_id = user.id
					t.finished = 0
					t.is_unlock = 1
					local a1 = user.u_achievementmgr.create(t)
					a1:__insert_db()
				elseif a.unlock_next_csv_id == "0" then
					break;
				else
					local a_src = game.g_achievementmgr:get_by_csv_id(a.unlock_next_csv_id)

					a.csv_id = a_src.csv_id
					a.finished = 0
					a.c_num = a_src.c_num
					a.unlock_next_csv_id = a_src.unlock_next_csv_id
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
	elseif type == const.EXP then
		-- repeat
		-- 	local a = user.u_achievementmgr:get_by_type(const.A_T_EXP)
		-- 	assert(a) -- must be only one
		-- 	local exp = user.u_propmgr:get_by_csv_id(const.EXP) -- abain prop by type (type -- csv_id -- prop.id)		
		-- 	local progress = exp.num / a.c_num
		-- 	if progress >= 1 then -- success
		-- 		a.finished = 100
		-- 		a.reward_collected = 0
		-- 		push_achievement(a)
				
		-- 		-- insert achievement rc	
		-- 		local rc = user.u_achievement_rcmgr.create(a)
		-- 		rc:__insert_db()

		-- 		local a_src = game.g_achievementmgr:get_by_csv_id(a.unlock_next_csv_id)

		-- 		a.csv_id = a_src.csv_id
		-- 		a.finished = 0
		-- 		a.c_num = a_src.c_num
		-- 		a.unlock_next_csv_id = a_src.unlock_next_csv_id
		-- 		a.is_unlock = 1
		-- 		a:__update_db({"csv_id", "finished", "c_num", "unlock_next_csv_id"})
		-- 	else
		-- 		a.finished = progress * 100
		-- 		a.finished = math.floor(a.finished)
		-- 		a:__update_db({"finished"})
		-- 		break
		-- 	end
		-- until false
	elseif type == "level" then
	end
end

function SUBSCRIBE:email( tvals, ... )
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
end

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
	local l = {}
	local idx = 1
	for k,v in pairs(user.u_achievementmgr.__data) do
		print(k,v)
	end
	for k,v in pairs(game.g_achievementmgr.__data) do
		local a = {
			csv_id = v.csv_id,
		}
		
		local rc2 = user.u_achievementmgr:get_by_csv_id(v.csv_id)
		if rc2 then
			print("***************************rc2", v.csv_id)
			a.finished = rc2.finished
			a.reward_collected = false
			a.is_unlock = (rc2.is_unlock == 1) and true or false
		else
			if v.is_init == 1 then
				local t = v:__serialize()
				t.user_id = user.id
				t.finished = 0         -- [0, 100]
				t.reward_collected = 1
				t.is_unlock = 1
				local achievement = user.u_achievementmgr.create(t)
				user.u_achievementmgr:add(achievement)
				achievement:__insert_db()
				
				-- raise_achievement(v.type, user, game)
				-- fix achievement value
				a.finished = 0
				a.reward_collected = false
				a.is_unlock = false
				
			end
		end
		local rc1 = user.u_achievement_rcmgr:get_by_csv_id(v.csv_id)
		if rc1 then
			a.finished = rc1.finished
			a.reward_collected = (rc1.reward_collected == 1) and true or false
			a.is_unlock = (rc1.is_unlock == 1) and true or false
		end

		if a.finished == nil then
			a.finished = 0
		end
		if a.reward_collected == nil then
			a.reward_collected = false
		end
		if a.is_unlock == nil then
			a.is_unlock = false
		end
		print("***********************is_unlock", a.is_unlock)
		l[idx] = a
		idx	= idx + 1
	end
	ret.errorcode = 0
    ret.msg = "this is all achievemtn."
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
	local a = user.u_achievement_rcmgr:get_by_csv_id(self.csv_id)
	if a and a.finished == 100 and a.reward_collected == 0 then
		a.collected = 1
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
	local ret = {}
	local r = math.random(1, 5)
	local addr = skynet.localname(string.format(".db%d", math.floor(r))) 
	local ok = skynet.call(addr, "lua", "signup", {self.account, self.password})
	if ok then
		ret.errorcode = 0
		ret.msg	= "yes"
		return ret
	else
		ret.errorcode = 1
		ret.msg = "no"
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
	local r = skynet.call(addr, "lua", "command", "select_user", { condition } )
    
	if not r then
		ret.errorcode = 1 -- 1 user hasn't register.
		ret.msg = "no"
		return ret
	else
		local usersmgr = require "models/usersmgr"
		user = usersmgr.create(r)
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

	dc.set(user.id, { client_fd=client_fd, addr=skynet.self()})
	local onlinetime = os.time()
	user.ifonline = 1
	user.onlinetime = onlinetime
	user:__update_db({"ifonline", "onlinetime"})

	user.emailbox = emailbox:loademails( user.id )
	emailrequest.getvalue( user )
	user.friendmgr = friendmgr:loadfriend( user , dc )
	friendrequest.getvalue( user , send_package , send_request )
	user.drawmgr = drawmgr
	drawrequest.getvalue( user )
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
			elseif assert(prop.use_type) == 2 then -- gold
				local g = user.u_propmgr:get_by_csv_id(const.GOLD)
				g.num = g.num + tonumber(prop.pram1)
				g:__update_db({"num"})
				wash.raise_achievement(const.A_T_GOLD, user, game)
			elseif assert(prop.use_type) == 3 then
				local csv_id1 = string.gsub(prop.pram1, "(%d*)%*(%d*)%*(%d*)%*(%d*)", "%1")
				local num1 = string.gsub(prop.pram1, "(%d*)%*(%d*)%*(%d*)%*(%d*)", "%2")
				local p1 = user.u_propmgr:get_by_csv_id(csv_id1)
				p1.num = p1.num + num1 * math.abs(v.num)
				p1:__update_db({"num"})
				local csv_id2 = string.gsub(prop.pram1, "(%d*)%*(%d*)%*(%d*)%*(%d*)", "%3")
				local num2 = string.gsub(prop.pram1, "(%d*)%*(%d*)%*(%d*)%*(%d*)", "%4")
				local p2 = user.u_propmgr:get_by_csv_id(csv_id2)
				p2.num = p2.num + num1 * math.abs(v.num)
				p2:__update_db({"num"})
				wash.raise_achievement(const.A_T_GOLD, user, game)
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
	local l = skynet.call(".shop", "lua", "shop_all")
	local ll = {}
	local idx = 1
	for i,v in ipairs(l) do
		local g = {
			csv_id = v.csv_id,
			currency_type = v.currency_type,
			currency_num = v.currency_num,
			g_prop_csv_id = v.g_prop_csv_id,
			g_prop_num = v.g_prop_num,
			inventory = v.inventory
		}
		if v.inventory == 0 then
			local now = os.time()
			if os.difftime(now, v.st) > v.cd then
				v.inventory = v.inventory_init
				g.inventory = v.inventory
				v:__update_db({"inventory"})
				g.countdown = v.cd
			else
				v.countdown = now - v.st
				g.countdown = v.countdown
				v:__update_db({"countdown"})
			end
		end
		ll[idx] = g
		idx = idx + 1
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
				local rc = user.u_purchase_goods.create(t)
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
	local idx = 1
	for k,v in pairs(game.g_recharge_vip_rewardmgr.__data) do
		local r = {}
		r.vip = v.vip
		r.props = {{csv_id=const.DIAMOND, num=v.diamond}}
		r.collected = user.u_recharge_vip_rewardmgr:get_by_vip(v.vip) and true or false
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
	-- local r = skynet.call(".shop", "lua", "recharge_purchase", self.g)
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
			rc.p_count = rc.p_count + 1
			rc:__update_db({"p_count"})
			local diamond = user.u_propmgr:get_by_csv_id(const.DIAMOND)
			diamond.num = diamond.num + (v.diamond + v.gift) * v.p_num
			diamond:__update_db({"num"})
		else
			rc = user.u_recharge_countmgr.create({user_id=user.id, g_recharge_csv_id=v.csv_id, p_count=1})
			rc:__insert_db()
			local diamond = user.u_propmgr:get_by_csv_id(const.DIAMOND)
			diamond.num = diamond.num + (v.diamond + v.gift) * v.p_num
			diamond:__update_db({"num"})
		end
		-----------------------------
		repeat
			local vip = game.g_recharge_vip_rewardmgr:get_by_vip(user.uviplevel + 1)
			if not vip then
				error "don't upgrade, no data."
			end
			local progress = user.recharge_diamond / vip.diamond
			print("***************", progress)
			if progress >= 1 then
				user.uviplevel = user.uviplevel + 1
				user:__update_db({"uviplevel"})
			else
				user.uvip_progress = progress * 100
				user:__update_db({"uvip_progress"})
				break
			end
		until false
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
    elseif nil ~= emailrequest[ name ] then
    	f = assert( emailrequest[ name ] )
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

function RESPONSE:newemail( e )
	assert( e )
	local ret = {}
   	ret.emailid = v.id
   	ret.type = v.type
  	ret.acctime = os.date("%Y-%m-%d" , v.acctime)
	ret.isread = ( v.isread == 0 ) 
   	ret.isreward = ( v.isreward  == 0 ) 
   	ret.title = v.title
   	ret.content = v.content
	ret.attachs = v:getallitem()
	ret.iconid = v.iconid
	return ret
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
