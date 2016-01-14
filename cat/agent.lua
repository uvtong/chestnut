package.path = "./../cat/?.lua;" .. package.path

local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local csvReader = require "csvReader"
local db = require "db"
local usermgr = require "user"

      	
local WATCHDOG
local host
local send_request
      
local CMD = {}
local REQUEST = {}
local client_fd
local csvcont = {}

local user_id
local role_id

function REQUEST:login( )
	-- body
end

function REQUEST:choosereos( ... )
	--TODO
end

function REQUEST:rechangerole( ... )
	role_id = self.id
	-- body
end

function REQUEST:role()
	user_id = self.id
	local user = usermgr.find( user_id )
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

function REQUEST:foobar()
	print("foobar is called")
	
	local tmp = csvReader.getline( csvcont , "Rolo" )

	return {
	ok = true,
      rolelist = {
         {
    ["isBoss"] = tonumber(tmp["isBoss"]),
    ["endWinCount"] = tonumber(tmp["endWinCount"]),
	
    ["health_Max"] = tonumber(tmp["health_Max"]),
    ["defense_Min"] = tonumber(tmp["defense_Min"]),


    ["redMakeStartTimeMin"] = tonumber(tmp["redMakeStartTimeMin"]),
    ["redMakeStartTimeMax"] = tonumber(tmp["redMakeStartTimeMax"]),
	
    ["bombMakePre"] = tonumber(tmp["bombMakePre"]),
    ["fastMakePre"] = tonumber(tmp["fastMakePre"]),
    ["groundMakePre"] = tonumber(tmp["groundMakePre"]),
    ["comboMakePre"] = tonumber(tmp["comboMakePre"]),
	
    ["attack1_Min"] = tonumber(tmp["attack1_Min"]),
    ["attack1_Max"] = tonumber(tmp["attack1_Max"]),
    ["attack1_TimeMin"] = tmp["attack1_TimeMin"],
    ["attack1_TimeMax"] = tmp["attack1_TimeMax"],
    ["attack1_CountMax"] = tonumber(tmp["attack1_CountMax"]),
    ["attack2_Min"]  = tonumber(tmp["attack2_Min"]),
    ["attack2_Max"] = tonumber(tmp["attack2_Max"]),
    ["attack2_TimeMin"] = tmp["attack2_TimeMin"],
    ["attack2_TimeMax"] = tmp["attack2_TimeMax"],
    ["attack2_CountMax"] = tonumber(tmp["attack2_CountMax"]),
    ["attackBoxMax"] = tonumber(tmp["attackBoxMax"]),
    ["attack3_Max"] = tonumber(tmp["attack3_Max"]),
 
    ["batter_Min"] = tonumber(tmp["batter_Min"]),
    ["batter_Max"] = tonumber(tmp["batter_Max"]),
 
    ["batter_ShowMin"] = tonumber(tmp["batter_ShowMin"]),
    ["batter_ShowMax"] = tonumber(tmp["batter_ShowMax"]),
    ["batter_TimeMin"] = tmp["batter_TimeMin"],
    ["batter_TimeMax"] = tmp["batter_TimeMax"],
    ["batter_CountMax"] = tonumber(tmp["batter_CountMax"]),
 
    ["combo_Min"] = tonumber(tmp["combo_Min"]),
    ["combo_Max"] = tonumber(tmp["combo_Max"]),
    ["combo_ShowMax"] = tonumber(tmp["combo_ShowMax"]),
    ["combo_CountMax"] = tonumber(tmp["combo_CountMax"]), 
	
    ["ground_Min"] = tonumber(tmp["ground_Min"]),
    ["ground_Max"] = tonumber(tmp["ground_Max"]),
    ["ground_TimeMin"] = tmp["ground_TimeMin"],
    ["ground_TimeMax"] = tmp["ground_TimeMax"],
    ["ground_CountMax"] = tonumber(tmp["ground_CountMax"]),
    ["ground_SpeedMin"] = tonumber(tmp["ground_SpeedMin"]),
    ["ground_CountClick"] = tonumber(tmp["ground_CountClick"]),
 
    ["fast_Min"] = tonumber(tmp["fast_Min"]),
    ["fast_Max"] = tonumber(tmp["fast_Max"]),
    ["fast_TimeMin"] = tmp["fast_TimeMin"],
    ["fast_TimeMax"] = tmp["fast_TimeMax"],
    ["fast_CountMax"] = tonumber(tmp["fast_CountMax"]),
    ["fast_SpeedMin"] = tonumber(tmp["fast_SpeedMin"]),
    ["fast_SpeedMax"] = tonumber(tmp["fast_SpeedMax"]),
	
    ["bomb_Min"] = tonumber(tmp["bomb_Min"]),
    ["bomb_Max"] = tonumber(tmp["bomb_Max"]),
    ["bomb_TimeMin"] = tmp["bomb_TimeMin"],
    ["bomb_TimeMax"] = tmp["bomb_TimeMax"],
    ["bomb_CountMax"] = tonumber(tmp["bomb_CountMax"]),
    ["bomb_SpeedMin"] = tonumber(tmp["bomb_SpeedMin"]),
    
    ["red_Min"] = tonumber(tmp["red_Min"]),
    ["red_Max"] = tonumber(tmp["red_Max"]),
    ["red_TimeMin"] = tmp["red_TimeMin"],
    ["red_TimeMax"] = tmp["red_TimeMax"],
    ["red_CountMax"] = tonumber(tmp["red_CountMax"]),
    ["red_SpeedMin"] = tonumber(tmp["red_SpeedMin"]),
    
    ["comboBoxShowMin"] = tonumber(tmp["comboBoxShowMin"]),
    
    ["defense_Max"] = tonumber(tmp["defense_Max"])
    },
}
}
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

	csvcont = csvReader.getcont( "./cat/data.csv" )
	print(package.path)
end)

