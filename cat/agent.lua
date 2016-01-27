package.path = "./../cat/?.lua;" .. package.path

local skynet = require "skynet"
require "skynet.manager"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local mc = require "multicast"
local sprotoloader = require "sprotoloader"
local mc = require "multicast"
local dc = require "datacenter"

local emailrequest = require "emailrequest"
local emailbox = require "emailbox"
local csvReader = require "csvReader"
local usermgr = require "usermgr" 
local rolemgr = require "rolemgr"

local WATCHDOG
local host
local send_request
      
local CMD = {}
local REQUEST = {}
local RESPONSE = {}
local client_fd
	 
local user
local level
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
		r[tostring(v[id])] = v[exp]
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

local function random_db()
	-- body
	local r = math.random(1, 5)
	local addr = skynet.localname(string.format(".db%d", math.floor(r))) 
	return addr
end

local function load_achievements( user )
	-- body
	local achievementmgr = require "achievementmgr"
	local addr = random_db()
	print ("**************load_achievements")
	local r = skynet.call(addr, "lua", "command", "select_achi", user.id)
	for i,v in ipairs(r) do
		local a = achievementmgr.create(v)
		achievementmgr:add(a)
	end
	user.achievementmgr = achievementmgr
end

local function load_roles( user )
	-- body
	local addr = random_db()
	local nr = skynet.call(addr, "lua", "command", "select_roles_by_userid", user.id)
	assert(nr)
	local rolemgr = require "rolemgr"
	print("..................im lien of role")
	for i,v in ipairs(nr) do
		local role = rolemgr:create( v )
		for k,v in pairs(role) do
			print(k,v)
		end
		rolemgr:add(role)
	end
	user.rolemgr = rolemgr
end

local function load_props( user )
	-- body
	print(".........................im props lien")
	local addr = random_db()
	local nr = skynet.call(addr, "lua", "command", "select_prop", user.id)
	assert(nr)
	print "******************************load_roles"
	local propmgr = require "propmgr"
	for i,v in ipairs(nr) do
		local prop = propmgr.create( v )
		propmgr:add(prop)
		for k,v in pairs(prop) do
			print(k,v)
		end
	end
	user.propmgr = propmgr
end

function REQUEST:signup()
	-- body
	local ret = {}
	local r = math.random(1, 5)
	local addr = skynet.localname(string.format(".db%d", math.floor(r))) 
	local ok = skynet.call(addr, "lua", "signup", {self.account, self.password})
	if ok then_
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
	print( "login is called\n" )

	level = csvReader.getcont("level")
	wakecost = csvReader.getcont("wake_cost")
	print "*****************8"
	for k,v in pairs(wakecost) do
		print ("................")
		print(k, v)
		for kk,vv in pairs(v) do
			print(kk,vv)
		end
	end
	wakecost = convert_wakecost(wakecost)

	local ret = {}
	local r = math.random(1, 5)
	local addr = skynet.localname(string.format(".db%d", math.floor(r))) 
	assert(self.account and	self.password)
	assert(#self.password > 1)
	local t = { uaccount = self.account, upassword = self.password }
	local r = skynet.call(addr, "lua", "command", "select_user", t )
	if not r then
		ret.errorcode = 1 -- 1 user hasn't register.
		ret.msg = "no"
		return ret
	else
		user = usermgr.create(r)
		usermgr:add( user )
		load_achievements(user)
		load_props(user)
		load_roles(user)
		ret.errorcode = 0
		ret.msg = "yes"
		ret.u = {
			uname = user.uname,
			uviplevel = user.uviplevel,
			config_sound = user.config_sound and true or false,
			config_music = user.config_music and true or false,
			avatar = user.avatar,
			sign = user.sign,
			c_role_id = user.c_role_id
		}
		-- all roles
		local l = {}
		local idx = 1
		for k,v in pairs(user.rolemgr._data) do
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
	
function REQUEST:upgrade()
	assert(user)
	print(self.role_id, user.c_role_id)
	assert(self.role_id == user.c_role_id)
	local ret = {}
	local role = user.rolemgr:find(self.role_id)
	local nowid = id(role.wake_level, role.level)
	print(nowid)
	local exp
	for k,v in pairs(level) do
		-- for kk,vv in pairs(v) do
		-- 	print(#kk, kk, vv)
		-- end
		if tonumber(v.id) < 3000 then
			print(v.id, v.exp)
		end
		if nowid == tonumber(v.id) then
			exp = tonumber(v.exp)
			print(exp)
			break
		end
	end
	if user.uexp > exp then
		user.uexp = user.uexp - exp
		role.level = role.level + 1
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
			c_kungfu = role.c_kungfu
		}
		return ret
	else
		print "*********8"
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

function REQUEST:props( ... )
	-- body
	assert(user)
	ret = {}
	local l = {}
	for k,v in pairs(user.propmgr) do
		print(k,v)
	end
	assert(user.propmgr._data)
	local idx = 1
	for k,v in pairs(user.propmgr._data) do
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
		local prop = user.propmgr:get_by_csvid(self.props[1].csv_id)
		if prop.num > 0 then
			prop.num = prop.num + self.props[1].num
			local addr = random_db()
			skynet.send(addr, "lua", "command", "update_prop", user.id, prop.csv_id, prop.num)
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
			local prop = user.propmgr:get_by_csvid(v.csv_id)
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
	for k,v in pairs(user.achievementmgr._data) do
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
    		print("***************************************getmsg*************************************\n")
    	end

    	local r = f(args)
    	if response then
    		return response(r)
    	end               
end      
	
local function response( name , args )
	local f = assert( RESPONSE[ name ] )
	f( args )
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

		elseif 0 == sz then
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
			--skynet.error "hello"--"heartbeat"
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

	assert(skynet.self())
	print(skynet.self())
	local c = skynet.call(".channel", "lua", "agent_start", 2, skynet.self())
	local c2 = mc.new {
		channel = c,
		dispatch = function ( channel, source, tvals , ... )
			-- body
			print("channel ****************************" , cmd )

			--print( tvals.type , tvals.iconid )

			print(tvals.emailtype , tvals.iconid )
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
	}
	c2:subscribe()
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
--[[print("--------------------------------------------------")
	local wakecost = csvReader.getcont( "Attribute" )
	for i , v in pairs( wakecost ) do
		print( i , v )
		for k , s in pairs( v ) do
			print( v.id , v.desp , v.exp  , v.time , v.time_1 )

		end
	end--]]
end)
