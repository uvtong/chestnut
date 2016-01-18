package.path = "./../cat/?.lua;" .. package.path

local skynet = require "skynet"
require "skynet.manager"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local csvReader = require "csvReader"
local datamgr = require "datamgr"
local usermgr = require "usermgr" 
local rolemgr = require "rolemgr"

local WATCHDOG
local host
local send_request
      
local CMD = {}
local REQUEST = {}
local client_fd
local csvcont = {}
	 
local role 
local uid

local user

function REQUEST:role()
	local r = {
		id = 0,
		wake_level = 1,
		level = 2,
		combat = 3,
		defense = 4,
		critical_hit = 6,
		skill = 7,
		c_equipment = 1,
		c_dress = 1,
		c_kungfu = 1
	}
	return r
	-- local r = math.random() % 5 + 1
	-- local addr = skynet.query( string.format(".db%d", r) ) 
	-- -- body
	-- local tvals = { tname = "role" , condition = string.format( "id = %s" , uid) }
	-- local r = skynet.call( addr, "command", "select" , tvals )
     
	-- return 
end	
					
function REQUEST:login()
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
		user = usermgr.create(r[0])
		ret.errorcode = 0
		ret.msg = "yes"
		ret.user_id = r[0].id
		ret.uname = r[0].uname
		ret.uviplevel = r[0].uviplevel
		ret.uexp = r[0].uexp
		ret.config_sound = r[0].config_sound
		ret.config_music = r[0].config_music
		ret.avatar = r[0].avatar
		ret.sign = r[0].sign
		ret.c_role_id = 0
	end

	t = { id = 1, nickname = "hh" , user_id = 1, wake_level = 1, level = 1, combat = 1, defense = 1, critical_hit = 1, skill = 1, c_equipment = 1, c_dress = 1, c_kungfu = 1}
	local r = rolemgr.create( t )
	local ret_r = { 
		role_id = r.id
		wake_level = r.wake_level
		level = r.wake_level
		combat = r.combat
		defense = r.defense
		critical_hit = r.critical_hit
		skill = r.skill
		c_equipment = r.c_equipment
		c_dress = r.c_dress
		c_kungfu = r.kungfu
	}
	local l = { ret_r }
	ret.rolelist = l
	return ret
end	
	
function REQUEST:choose_role()
	user.c_role_id = self.role_id
	local ret = {}
	ret.errorcode = 0
	ret.msg	= "yes"
	return ret
end	
	
function REQUEST:upgrade()
	local = ret = {}
	local role = rolemgr.find(user.c_role_id)
	local err
	local nowid = role.id * 1000 + role.wake_level
	local wakecost = datamgr:findwakeattrItem( tostring( nowid ) )
	local afterid = wakecost["afrerwakeid"]
	local wakeattr = datamgr:findwakecostItem( tostring( afterid ) ) 
	if role.level < tonumber(wakecost["needlevel"]) then
		ret.errorcode = 1
		ret.msg = ""
		return ret
	elseif role:getgold() < tonumber(wakecost["costgold"]) then
		ret.errorcode = 2
		ret.msg = ""
		return ret
	else
		ret.errorcode = 0
		ret.msg = ""
		ret.role_id = role.id
		role.level = role.level + 1
		ret.level = role.level
	end	
end		
		
function REQUEST:wake()
	local ret = {}
	local role = {}
	local nowid = role.id * 1000 + role.wake_level

	local wakecost = datamgr:findwakeattrItem( nowid )
	local afterid = wakecost["afrerwakeid"]

	if role:getlevel() < tonumber(wakecost["needlevel"]) then
		ret.err = 1
		ret.msg = ""
		return ret
		
	elseif role:getgold() < tonumber(wakecost["costgold"]) then
		ret.errorcode = 2
		ret.msg	= ""
		return ret
	else
		ret.errorcode = 0
		ret.msg	 = ""
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
	print "cmd .start."
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
	-- print( "agent start is called\n" )
	
	datamgr:startload()
	--csvcont = csvReader.getcont( "./cat/data.csv" )
	--print(package.path)
end)

