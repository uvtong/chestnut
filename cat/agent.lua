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
local csvReader = require "csvReader"

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

local function send_achievement( achievement )
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
									
local function achi( type, ... )
	-- body
	if type == "combat" then
		local n = tonumber(...)
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
	elseif type == "gold" then
		local prop = user.propmgr:get_by_type(type) -- abain prop by type (type -- csv_id -- prop.id)
		local l = user.achievementmgr:get_by_type(type)
		-- sort
		for i,v in ipairs(l) do
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
	local ok = skynet.call(util.random_db(), "lua", "command", "signup", {self.account, self.password})
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
		usersmgr:add( user )
		skynet.fork(subscribe)
		-- load
		loader.load_user(user)
		print(">>>>>>>>>>>>>>>", type(usersmgr))
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
			uexp = user.u_propmgr:get_by_csv_id(3).num,
			gold = user.u_propmgr:get_by_csv_id(2).num,
			diamond = user.u_propmgr:get_by_csv_id(1).num
		}
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

	user.emailbox = emailbox:loademails( user.id )
	emailrequest.getvalue( user )
	return ret
end	

function REQUEST:logout()
	-- body
	skynet.call(WATCHDOG, "lua", "close", client_fd)
end

function REQUEST:role()
	assert(user)
	assert(self.role_id)
	local role = rolemgr:find(self.role_id)
	local ret = {
		errorcode = 0,
		msg = "",
		r = {
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
		local role = assert(user.rolemgr:find(user.c_role_id))
		ret.r = role
		return ret
	end
end	
	
function REQUEST:role_upgrade_star()
	assert(user)
	print(self.role_id, user.c_role_id)
	assert(self.role_id == user.c_role_id)
	local ret = {}
	local role = user.rolemgr:find(self.role_id)
	local prop = user.propmgr:get_by_csvid(self.role_id)
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
	local role = user.rolemgr:find(self.role_id)
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
	local a = user.achievementmgr:get_by_csv_id(self.csv_id)
	if a and a.finished == 100 and a.collected == 0 then
		a.collected = 1
		skynet.send(util.random_db(), "lua", "command", "update", "achievements", {{ user_id = user.id, csv_id = a.csv_id}}, { collected = a.collected})
		local prop = user.propmgr:get_by_csvid(a.reward_id)
		if prop then
			prop.num = prop.num + a.reward_num
			skynet.send(util.random_db(), "lua", "command", "update", "props", {{ id = prop.id }}, { num = prop.num})
		else
			local t = { user_id = user.id, prop_id = a.reward_id, num = a.reward_num}
			skynet.send(util.random_db(), "lua", "command", "insert", "props", t)
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
	user.uname = self.name
	skynet.send(util.random_db(), "lua", "command", "update", "users", {{ id = user.id }}, { modify_uname_count = user.modify_uname_count, uname = user.uname})
	local ret = {}
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
	local exp = user.u_propmgr:get_by_csv_id(3).num
	print("888", exp)
	if exp > tonumber(L.exp) then
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
	assert(user)
	return skynet.call(".shop", "lua", "shop_all")
end

function REQUEST:shop_refresh()
	-- body
	assert(user)
	return skynet.call(".shop", "lua", "shop_refresh", self.goods_id)
end

function REQUEST:shop_purchase()
	-- body
	local ret = {}
	local l = skynet.call(".shop", "lua", "shop_purchase", self.g)
	for k,v in pairs(l) do
		local goods = v
		if goods.c_a_num == 0 then
			ret.errorcode = 1
			ret.msg = "no enough goods"
			return ret
		else
			local c_startingtime = goods.c_startingtime
		end
		if goods.currency_type == 2 then
			local gold = goods.currency_num * goods.p_num
			-- gold 2
			local currency = user.propmgr:get_by_csvid(goods.currency_type)
			if currency.num > gold then
				currency.num = currency.num - gold
				skynet.send(util.random_db(), "lua", "command", "update", "props", {{ id = prop.id }}, { num = prop.num })
				local prop = user.propmgr:get_by_csvid(goods.prop_csv_id)
				if prop then
					prop.num = prop.num + goods.prop_num * goods.p_num
					skynet.send(util.random_db(), "lua", "command", "update", "props", {{ id = prop.id }}, { num = prop.num })
				else
					local t = {user_id = user.id, csv_id = prop.csv_id, prop_csv_id = prop.prop_csv_id, num = goods.prop_num * goods.p_num}
					local prop = user.propmgr.create(t)
					user.propmgr:addr(prop)
					skynet.send(util.random_db(), "lua", "command", "insert", "props", t)
				end
				ret.errorcode = 0
				ret.msg	= "yes, take gold"
				return ret
			else
				ret.errorcode = 1
				ret.msg	= string.format("yes, no enough gold, only %d", goods.gold)
				return ret
			end
		elseif goods.currency_type == 1 then
			local diamond = goods.currency_num * goods.p_num
			local currency = user.propmgr:get_by_csvid(goods.currency_type)
			if currency.num > diamond then
				currency.num = currency.num - diamond
				skynet.send(util.random_db(), "lua", "command", "update", "props", {{ id = currency.id }}, { num = currency.num })
				local prop = user.propmgr:get_by_csvid(goods.prop_csv_id)
				if prop then
					prop.num = prop.num + goods.prop_num * goods.p_num
					skynet.send(util.random_db(), "lua", "command", "update", "props", {{ id = prop.id }}, { num = prop.num, prop_pram1 = prop.pram1 })
				else
					local t = {user_id = user.id, csv_id = goods.prop_csv_id, prop_csv_id = goods.prop_csv_id, num = goods.prop_num * goods.p_num, prop_pram1 = prop.pram1}
					local prop = user.propmgr.create(t)
					user.propmgr:add(prop)
					skynet.send(util.random_db(), "lua", "command", "insert", "props", t)
				end
				ret.errorcode = 0
				ret.msg	= "yes, take diamond"
				return ret
			else
				ret.errorcode = 1
				ret.msg	= "no diamond"
				return ret
			end
		else
			assert(false)
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
		repeat 
			print("**************************")
			local v1 = game.g_recharge_vipmgr:get_by_vip(vip)
			local v2 = game.g_recharge_vipmgr:get_by_vip(vip + 1)
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
		local prop = user.propmgr:get_by_csvid(1)
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

local function request( name, args, response )
	print( "request name :" .. name )
    	local f = nil
    	if nil ~= REQUEST[name] then
    		f = assert(REQUEST[ name ])
    	elseif nil ~= emailrequest[ name ] then
    		f = assert( emailrequest[ name ] )
    	else
    		assert(false)
    	end
    	local r = f(args)
    	if response then
    		return response(r)
    	end               
end      
	
local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
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
	
skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		print("agent is called" , command)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
