package.path = "./../cat/?.lua;" .. package.path

local skynet = require "skynet"
require "skynet.manager"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local csvReader = require "csvReader"
local usermgr = require "usermgr" 

local WATCHDOG
local host
local send_request
      
local CMD = {}
local REQUEST = {}
local client_fd
	 

local user
local level
local wakeattr
local wakecost

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
		r[tostring(v[id])] = v
	end
	return r
end

local function id( __level, __wake )
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
					
function REQUEST:login()
	level = csvReader.getcont("level")
	level = convert_level(level)
	wakecost = csvReader.getcont("wake_cost")
	wakecost = convert_wakecost(wakecost)

	local ret = {}
	local r = math.random(1, 5)
	local addr = skynet.localname(string.format(".db%d", math.floor(r))) 
	assert(self.account and	self.password)
	assert(#self.password > 1)
	local t = { uaccount = self.account, upassword = self.password }
	local r = skynet.call(addr, "lua", "command", "select_users", t )

	if r == nil or r[1] == nil then
		ret.errorcode = 1 -- 1 user hasn't register.
		ret.msg = "no"
		return ret
	else
		user = usermgr:create(r[1])
		usermgr:add( user )

		local nr = skynet.call(addr, "lua", "command", "select_roles_by_userid", user.id)
		assert(nr)
		local rolemgr = require "rolemgr"
		if true then
			for k,v in pairs(nr) do
				local role = rolemgr:create( v )
				print( "new role id is " .. role.id )
				rolemgr:add(role)
			end
		else
			for i=1,5 do
				local r = {
					id = i,
					wake_level = 1,
					level = 1,
					combat = 3,
					defense = 4,
					critical_hit = 6,
					skill = 7,
					c_equipment = 1,
					c_dress = 1,
					c_kungfu = 1
				}
				local role = rolemgr:create(r)
				for k,v in pairs(role) do
					print(k,v)
				end
				rolemgr:add(role)
			end
		end
		user.c_role_id = 1
		user.rolemgr = rolemgr

		ret.errorcode = 0
		ret.msg = "yes"
		ret.user_id = user.id
		ret.uname = user.uname
		ret.uviplevel = user.uviplevel
		ret.uexp = user.uexp
		ret.config_sound = user.config_sound and true or false
		ret.config_music = user.config_music and true or false
		ret.avatar = user.avatar
		ret.sign = user.sign
		ret.c_role_id = 0

		local l = {}
		local idx = 1
		for k,v in pairs(rolemgr._data) do
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
	return ret
end	
	
function REQUEST:choose_role()
	puser.c_role_id = self.role_id
	local ret = {}
	ret.errorcode = 0
	ret.msg	= "yes"
	return ret
end	
	
function REQUEST:upgrade()
	local ret = {}
	local role = rolemgr:find(user.c_role_id)
	local err
	local nowid = id(role.wake_level, role.level)
	local exp = level[tostring(nowid)]
	if user.uexp > exp then
		user.uexp = user.uexp - exp
		role.level = role.level + 1
		-- return
		ret.errorcode = 0
		ret.msg = ""
		ret.role_id = role.id
		ret.wake_level = role.wake_level
		ret.level = role.level
		ret.combat = role.combat
		ret.defense = role.defense
		ret.critical_hit = role.critical_hit
		ret.skill = role.skill
		ret.c_equipment = role.c_equipment
		ret.c_dress = role.c_dress
		ret.c_kungfu = role.c_kungfu
		return ret
	else
		ret.errorcode = 1
		ret.msg = "no"
		return ret
	end
end		
		
function REQUEST:wake()
	local ret = {}
	local role = rolemgr:find(user.c_role_id)
	local nowid = id(role.wake_level, role.level)
	local cost = wakecost[tostring(role.wake_level)]
	if role.level > cost.level and user.gold > cost.gold then
		role.wake_level = role.wake_level + 1
		role.level = role.level - 1
		user.gold = user.gold - cost.gold
		ret.errorcode = 0
		ret.msg = "yes"
		ret.role_id = role.id
		ret.wake_level = role.wake_level
		ret.level = role.level
		ret.combat = role.combat
		ret.defense = role.defense
		ret.critical_hit = role.critical_hit
		ret.skill = role.skill
		ret.c_equipment = role.c_equipment
		ret.c_dress = role.c_dress
		ret.c_kungfu = role.c_kungfu
		return ret
	else
		ret.errorcode = 1
		ret.msg	= ""
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
	print( "request name :" .. name)
    	local f = assert(REQUEST[name])
    	local r = f(args)
    	if response then
    		return response(r)
    	end               
end      

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		if sz > 0 then
			return host:dispatch(msg, sz)
		else
			skynet.error " error"
			return "HELLO"
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
		elseif type == "HELLO" then
			skynet.error "hello"
		else
			assert(type == "RESPONSE")
			error "This example doesn't support request client"
		end
	end
}	

function CMD.start(conf)
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
end	
	
function CMD.disconnect()
	-- todo: do something before exit
	skynet.exit()
end	
	
function printcont( cont )
	if cont ~= nil then
		for i, v in ipair(cont) do
			print(i, v)
		end
	end
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		print("agent is called")
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)

