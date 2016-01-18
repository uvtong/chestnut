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
require "role"
     	

local WATCHDOG
local host
local send_request
      
local CMD = {}
local REQUEST = {}
local client_fd
local csvcont = {}
	 
local role 
local uid
	 
function REQUEST:role()
	local r = math.random() % 5 + 1
	local addr = skynet.query( string.format(".db%d", r) ) 
	-- body
	local tvals = { tname = "role" , condition = string.format( "id = %s" , uid) }
	local r = skynet.call( addr, "command", "select" , tvals )
     
	return 
end	
					
function REQUEST:mail()
     
end	 
	 
function REQUEST:signup()
end	
	
function REQUEST:login()
	local t = math.random() % 5 + 1
	local addr = skynet.localname( string.format(".db%d", 1) ) 
    local err 
    print("add is " .. type(addr), addr)

	local tvals = { tname = "users" , condition = string.format( "uaccount = %s , upassword = %s" , self.account , self.password ) }
	local r = skynet.call( addr, "command", "select_users" , tvals )
	if r == nil or r[1] == nil then
		skynet.error( "no such user!" )
		err = 1
	end

	local u = usermgr.create( r[1] )
	uid = u.id

	print "****************************************"
	tvals = nil
	tvals = { tname = "role" , condition = string.format( "uid = %s" , uid ) }
	r = skynet.call( addr , "command" , "select_rolebyuid" , tvals )

	print("load data succ\n")
	local ret = {}
	local rolelist = {}
	for k , v in ipairs( r ) do
		tmp = rolemgr.create( r )
		local rl = {}

		rl.id = tmp.id
		rl.wake_level = tmp.wake_level
		rl.level = tmp.level
		rl.combat = tmp.combat
		rl.defense = tmp.defense
		rl.critical = tmp.critical
		rl.skill = tmp.skill
		rl.c_equipment = tmp.c_equipment
		rl.dress = tmp.c_equipment
		rl.kungfu = tmp.kungfu

		table.insert( rolelist , rl )
	end
	ret.rolelist = rolelist
	
	ret.id = u.id;
	ret.uname = u.uname
	ret.uaccount = u.uaccount
	ret.upassword = u.password
	ret.uviplevel = u.uviplevel
	ret.uexp = u.uexp
	ret.config_sound = u.config_sound
	ret.config_music = u.config_music
	ret.avatar = u.avatar
	ret.sign = u.sign
    
	return ret
end	
	
function REQUEST:chooserole()
	local r = rolemgr:find( self.role_id )
	if nil ~= r then
		role = r
	end
end	
	
function REQUEST:upgrade()
	local err
	nowid = role._id * 1000 + role._wake_level

	wakecost = datamgr:findwakeattrItem( tostring( nowid ) )
	local afterid = wakecost["afrerwakeid"]

	wakeattr = datamgr:findwakecostItem( tostring( afterid ) ) 

	if role:getlevel() < tonumber(wakecost["needlevel"]) then
		err = 1
	elseif role:getgold() < tonumber(wakecost["costgold"]) then
		err = 2
	end	
	
	local ret = {}

	if nil == self.error then
		ret.error = 0
		ret.wake_level = role.wake_level 

		role._wake_level = role._wake_level + 1
		role._gold = role.gold - tonumber(wakecost["costgold"])


	end	
end		
		
function REQUEST:wake()
	local err
	local nowid = role._id * 1000 + role._wake_level

	wakecost = datamgr:findwakeattrItem( nowid )
	local afterid = wakecost["afrerwakeid"]

	--wakeattr = datamgr:findwakecostItem( afterid ) 

	if role:getlevel() < tonumber(wakecost["needlevel"]) then
		err = 1
	elseif role:getgold() < tonumber(wakecost["costgold"]) then
		err = 2
	end	
	
	local ret = {}

	if nil == self.error then
		ret.error = 0
		ret.wake_level = role.wake_level 

		role._wake_level = role._wake_level + 1
		role._gold = role.gold - tonumber(wakecost["costgold"])
	else
		ret.error = err
	end	

	return ret
end		
		
function REQUEST:get()
	print("get", self.what)
	local r = skynet.call("SIMPLEDB", "lua", "get", self.what)
	return { result = r }
end		
		
function REQUEST:set()
	print("set", self.what, self.value)
	local r = skynet.call("SIMPLEDB", "lua", "set", self.what, self.value)
end		
		
function REQUEST:handshake()
	print("Welcome to skynet, I will send heartbeat every 5 sec." )
	return { msg = "Welcome to skynet, I will send heartbeat every 5 sec." }
end		
		
function REQUEST:quit()
	skynet.call(WATCHDOG, "lua", "close", client_fd)
end

function REQUEST:blackhole()
	local t = math.random() % 5 + 1
	local addr = skynet.localname( string.format(".db%d", 1) ) 
    local err 
    print("add is " .. type(addr), addr)

	local tvals = { tname = "users" , condition = string.format( "uaccount = %s , upassword = %s" , "abc" , "abc" ) }
	local r = skynet.pcall( addr, "command", "select_users" , tvals )
	print( "called succe" )
	print( self.account , self.password)
	 if r == nil or r[1] == nil then
	 	skynet.error( "no such user!" )
	 	err = 1
	 end

	 local u = usermgr.create( r[1] )
	 uid = u.id

	 print "****************************************"
	tvals = nil
	 tvals = { tname = "role" , condition = string.format( "uid = %s" , uid ) }
	 r = skynet.call( addr , "command" , "select_rolebyuid" , tvals )

	print("load data succ\n")
	local ret = {}
	local rolelist = {}
	for k , v in ipairs( r ) do
		tmp = rolemgr.create( r )
		local rl = {}

		rl.id = tmp.id
		rl.wake_level = tmp.wake_level
		rl.level = tmp.level
		rl.combat = tmp.combat
		rl.defense = tmp.defense
		rl.critical = tmp.critical
		rl.skill = tmp.skill
		rl.c_equipment = tmp.c_equipment
		rl.dress = tmp.c_equipment
		rl.kungfu = tmp.kungfu

		table.insert( rolelist , rl )
	end
	ret.rolelist = rolelist
	
	ret.id = u.id;
	ret.uname = u.uname
	ret.uaccount = u.uaccount
	ret.upassword = u.password
	ret.uviplevel = u.uviplevel
	ret.uexp = u.uexp
	ret.config_sound = u.config_sound
	ret.config_music = u.config_music
	ret.avatar = u.avatar
	ret.sign = u.sign
    
	return ret
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
	skynet.fork(function()
		while true do
			send_package(send_request "heartbeat")
			skynet.sleep(500)
		end
	end)
	
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
	print( "agent start is called\n" )
	
	datamgr:startload()
	--csvcont = csvReader.getcont( "./cat/data.csv" )
	--print(package.path)
end)

