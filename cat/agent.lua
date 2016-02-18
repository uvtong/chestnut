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

local M = {}
local battlerequest = require "battlerequest"
table.insert(M, battlerequest)

local WATCHDOG
local host
local send_request
      
local CMD = {}
local REQUEST = {}
local RESPONSE = {}
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

local function push_achievement(achievement)
	-- body
	ret = {}
	ret.which = {
		csv_id = achievement.csv_id,
		finished = achievement.finished
	}
	send_package(send_request("finish_achi", ret))
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

local SUBSCRIBE = {}

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
	dc.set(user.id, { client_fd=client_fd, addr = skynet.self()})

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
									
local function raise_achievement(t)
	-- body
	if type == "combat" then
		local n = 0
		local l = user.achievementmgr:get(type)
		for i,v in ipairs(l) do
			local z = n / v.combat
			if z > 1 then
				send_achi(v.csv_id, z)
			end
			v.finished = z
			local addr = random_db()
			skynet.send(addr, "lua", "command", "update", "achievements", {user_id = user.id, type = "combat", combat= v.combat}, {finished = v.finished})	
		end
		for k,v in pairs(l) do
			print(k,v)
		end
		if num > 1000 then
			send_achi()
		end
	elseif type == "gold" then -- 2
		local prop = user.u_propmgr:get_by_csv_id(const.GOLD) -- abain prop by type (type -- csv_id -- prop.id)
		local lu = user.u_achievementmgr:get_by_type(type)
		-- sort
		for i,v in ipairs(lg) do
			if prop.num > v.gold then
				v.finished = math.floor(prop.num / v.gold * 100)
				skynet.fork(function ()
					-- body
					send_achi(v.csv_id, v.finished)
				end)
				local addr = random_db()
				skynet.call(addr, "lua", "command", "achievements", {user_id = user.id, csv_id = v.csv_id, type = "gold"}, { finished = v.finished })
			end	
		end
	elseif type == "kungfu" then
	elseif type == "raffle" then
	elseif type == "exp" then
	elseif type == "level" then
	end
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

	level = csvReader.getcont("level")
	wakecost = csvReader.getcont("wake_cost")
	wakecost = convert_wakecost(wakecost)
    
	if not r then
		ret.errorcode = 1 -- 1 user hasn't register.
		ret.msg = "no"
		return ret
	else
		
		local usersmgr = require "models/usersmgr"
		user = usersmgr.create(r)
		loader.load_user(user)
		
		skynet.fork(subscribe)

		local level = csvReader.getcont("level")
		level_limit = convert_level(level)

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
	print("*************************afb")
	user:__update_db({"ifonline", "onlinetime"})
	print("*************************afbc")
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
	user.__update_db({"ifonline"})
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
	for k,v in pairs(user.u_propmgr) do
		print(k,v)
	end
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
	assert(user)
	local ret = {}
	if #self.props == 1 then
		local prop = user.u_propmgr:get_by_csv_id(self.props[1].csv_id)
		if prop.num > 0 then
			prop.num = prop.num + self.props[1].num
			prop:__update_db({"num"})
			ret.errorcode = 0
			ret.msg	= "yes"
			if prop.num ~= 0 then
				ret.props = {{csv_id = prop.csv_id, num = prop.num}}
			end
			return ret
		else
			assert(prop.num > v.num)
			prop.num = prop.num - self.props[1].num
			local addr = random_db()
			skynet.send(addr, "lua", "command", "update_prop", user.id, prop.csv_id, prop.num)		
			if prop.csv_id == 690001 then
				local p = user.u_propmgr:get_by_csv_id(3)
				p.num = p.num + prop.prop_pram1
				skynet.send(util.random_db(), "lua", "command", "update", "props", {{ user_id = user.id, csv_id = p.csv_id}}, { num = p.num })
			elseif prop.csv_id == 690002 then
				local p = user.u_propmgr:get_by_csv_id(2)
				p.num = p.num + prop.prop_pram1
				skynet.send(util.random_db(), "lua", "command", "update", "props", {{ user_id = user.id, csv_id = p.csv_id}}, { num = p.num })
			end
			assert(self.role_id == user.c_role_id)
			local role = user.rolemgr:find(self.role_id)
			role.combat = role.combat + (prop.combat * 1)
			-- skynet.send(addr, "lua", "command", "update_role")
			ret.errorcode = 0
			ret.msg	= "yes"
			ret.props = {{csv_id = prop.csv_id, num = prop.num}}
			ret.role = role
			return ret
		end
	else
		local props = {}
		local idx = 1
		for k,v in pairs(self.props) do
			-- update databse
			local prop = user.u_propmgr:get_by_csv_id(v.csv_id)
			assert(v.num > 0)
			prop.num = prop.num + v.num
			local addr = random_db()
			skynet.send(addr, "lua", "command", "update_prop", user.id, prop.csv_id, prop.num)		
			props[idx] = {csv_id = prop.csv_id, num = prop.num}
		end
		ret.errorcode = 0
		ret.msg = "yes"
		ret.props = props
		return ret
	end
end

function REQUEST:achievement()
	-- body
	assert(user)
	local ret = {}
	local l = {}
	local idx = 1
	for k,v in pairs(user.u_achievementmgr.__data) do
		local a = {
			csv_id = v.csv_id,
    		finished = v.finished
		}
		print(v.csv_id, v.finished)
		l[idx] = a
		idx	= idx + 1
	end
	-- send_achi(2, 40)
	ret.errorcode = 0
    ret.msg = "yes"
    ret.achis = l
    return ret
end

function REQUEST:achievement_reward_collect()
	-- body
	local ret = {}
	assert(user)
	local a = user.u_achievementmgr:get_by_csv_id(self.csv_id)
	if a and a.finished == 100 and a.collected == 0 then
		a.collected = 1
		skynet.send(util.random_db(), "lua", "command", "update", "achievements", {{ user_id = user.id, csv_id = a.csv_id}}, { collected = a.collected})
		local prop = user.u_propmgr:get_by_csv_id(a.reward_id)
		if prop then
			prop.num = prop.num + a.reward_num
			prop:__update_db({"num"})
		else
			local prop = game.g_propmgr:get_by_csv_id(a.reward_id)
			prop.user_id = user.id
			prop.num = a.reward_num
			prop = user.u_propmgr.create(prop)
			prop:__insert_db()
		end
		ret.errorcode = 0
		ret.msg = "yes"
		return ret
	end
	ret.errorcode = 1
	ret.msg = "no"
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
    	recharge_total = user.recharge_total,
    	recharge_diamond = user.recharge_diamond,
    	recharge_progress = user.recharge_progress,
    	recharge_vip = user.recharge_vip
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

local function add_achievement()
	-- body
	local t = 2
	local lg = game.g_achievementmgr:get_by_type_and_level(t, user.level)
	for k,v in pairs(lg) do
		v.user_id = user.id
		v.finished = 10
		local a = user.u_achievementmgr.create(v)	
		user.u_achievementmgr:add(a)
		a:__insert_db()
	end
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
			end
		end
		g.countdown = v.cd
		ll[idx] = g
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
	local rc = game.g_goods_refresh_cost:get_by_csv_id(self.goods_id)
	local p = user.u_propmgr:get_by_csv_id(rc.currency_type)
	if p.num > rc.currency_num then
		p.num = p.num - rc.currency_num
		p:__update_db({"num"})
		ret.errorcode = 0
		ret.msg = "yes"
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
	-- 5 other
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
				currency.num = currency.num - gold
				currency:__update_db({"num"})
				local prop = user.propmgr:get_by_csvid(goods.g_prop_csv_id)
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
					prop = user.propmgr.create(prop)
					user.propmgr:add(prop)
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

function REQUEST:checkin_schedule()
	-- body
	local ret = {}
	return ret
	-- local c_date = os.date()
	-- local sql = "select * from checkin where CDate(Format("
	-- local checkins = skynet.call(util.random_db(), "lua", "command", "query", )
end

function REQUEST:checkin()
	-- body
	local ret = {}
	local c_date = os.date()
	local checkins = skynet.call(util.random_db(), "lua", "command", "select", "checkin", {{ user_id = user.id, s_checkin_date = c_date}})
	if #checkins > 1 then
	end
	return ret
end

function REQUEST:raffle()
	-- body
	local ret = {}
	if self.raffle_type == 1 then
		local prop = user.propmgr:get_by_csvid(4)
		if prop.num > 100 then
			prop.num = prop.num - 100
			ret.errorcode = 1
			ret.msg = "yes"
			return ret
		else
			ret.errorcode = 0
			ret.msg = "no"
			return ret
		end
	elseif self.raffle_type == 2 then
		local prop = user.propmgr:get_by_csvid(2)
		if prop.num > 280 then
			prop.num = prop.num - 280
			skynet.send(util.random_db(), "lua", "command", "update", "props", {{ user_id = user.id, csv_id = prop.csv_id }}, { num = prop.num})
			ret.errorcode = 1
			ret.msg = "yes"
			return ret
		else
			ret.errorcode = 0
			ret.msg	= "no"
			return ret
		end
	elseif self.raffle_type == 3 then
		local prop = user.propmgr:get_by_csvid(2)
		if prop.num > 2580 then
			prop.num = prop.num - 2580
			skynet.send(util.random_db(), "lua", "command", "update", "props", {{ user_id = user.id, csv_id = prop.csv_id }}, { num = prop.num})
			ret.errorcode = 0
			ret.msg = "yes"
			return ret
		else
			ret.errorcode = 1
			ret.msg	 = "no"
			return ret
		end
	end	
end

function REQUEST:recharge_all()
	-- body
	return skynet.call(".shop", "lua", "recharge_all")
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

function REQUEST:recharge_purchase()
	-- body
	local ret = {}
	local r = skynet.call(".shop", "lua", "recharge_purchase", self.g)
	if #r == 0 then
		ret.errorcode = 1
		ret.msg = "no exist"
		return ret
	end
	for i,v in ipairs(r) do
		
		-- purchase successful 
		print(user.recharge_total)
		print(v.rmb)
		-- this is error .
		user.recharge_total = user.recharge_total + v.rmb * v.p_num
		user.recharge_diamond = user.recharge_diamond + v.diamond * v.p_num
		local vip = user.recharge_vip
		print(vip)
		repeat
			local v1 = game.g_recharge_vipmgr:get_by_vip(vip)
			local v2 = game.g_recharge_vipmgr:get_by_vip(vip + 1)
			if not v1 or not v2 then
				break
			end
			print(user.recharge_diamond, "kjdfa", v1.diamond, "KKK", v2.diamond)
			if user.recharge_diamond < v2.diamond and user.recharge_diamond > v1.diamond then
				user.recharge_vip = vip
				print("vip", vip)
				user.recharge_progress = math.tointeger((user.recharge_diamond - v1.diamond) / (v2.diamond - v1.diamond) * 100)
				break
			end
			vip = vip + 1
		until false
		skynet.send(util.random_db(), "lua", "command", "update", "users", {{ id = user.id }}, { recharge_total = user.recharge_total, recharge_diamond = user.recharge_diamond, recharge_progress = user.recharge_progress, recharge_vip = user.recharge_vip })
		local prop = user.u_propmgr:get_by_csv_id(1)
		print(prop.num)
		prop.num = prop.num + v.diamond * v.p_num
		skynet.send(util.random_db(), "lua", "command", "update", "props", {{ id = prop.id }}, { num = prop.num })
		ret.errorcode = 0
		ret.msg = "yes"
		ret.p = {
			csv_id = prop.csv_id,
    		num = prop.num
    	}
    	return ret
	end
	ret.errorcode = 2
	ret.msg = "occour error."
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
    assert(f)
    local r = f(args)
    if name == "login" then
    	for k,v in pairs(M) do
    		if v.REQUEST then
    			v.REQUEST[name](user)
    		end
    	end
    end
    print("*___________________________*", name)
    if response then
    	return response(r)
    end               
end      
	
local RESPONSE = {}

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
	
local SUBSCRIBE = {}
	
function SUBSCRIBE:email( tvals, ... )
	-- body
	local v = emailbox:recvemail( tvals )
	local ret = {}
	ret.mail = {}
	local tmp = {}
   	tmp.attachs = {}
    tmp.emailid = v.id
    tmp.type = v.type
    tmp.acctime = os.date("%Y-%m-%d" , v.acctime)
    tmp.isread = v.isread
    tmp.isreward = v.isreward
    tmp.title = v.title
    tmp.content = v.content
	tmp.attachs = v:getallitem()
	tmp.iconid = v.iconid
	ret.mail = tmp
	send_package( send_request( "newemail" ,  ret ) )
end	
	
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

	local c = skynet.call(".channel", "lua", "agent_start", 2, skynet.self())
	local c2 = mc.new {
		channel = c,
		dispatch = function ( channel, source, cmd, tvals , ... )
			-- body
			local f = assert(SUBSCRIBE[cmd])
			f(tvals, ...)
		end
	}
	c2:subscribe()

	game = loader.load_game()
	for i,v in ipairs(M) do
		v.start(conf, send_request, game, dc)
	end
end	
	
function CMD.channel( cn )
	print("channeled is called\n" , cn)
	local c2 = mc.new {
		channel = cn,
		dispatch = function ( channel, source, et )
			print( et.id , et.uid )
		end,
	}
	print("subscribe already")
	c2:subscribe()
	skynet.send(addr, "lua", "publish" )
end
   
function CMD.disconnect()
	-- todo: do something before exit
	skynet.exit()
end	

function CMD.friend( subcmd, ... )
	-- body
	local f = assert(friendrequest[subcmd])
	return f(friendrequest, ...)
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		print("agent is called" , command)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
