local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local crypt = require "crypt"

local WATCHDOG
local host
local send_request

local REQUEST = {}
local client_fd

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
	skynet.error "handshake"
	return { msg = "Welcome to skynet, I will send heartbeat every 5 sec." }
end

function REQUEST:quit()
	skynet.call(WATCHDOG, "lua", "close", client_fd)
end

local function request(name, args, response)
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
	
	-- pack return lua string or userdata and size.
	-- unpack = skynet.tostring, skynet.tostring covert msg and sz to lua string
	-- local ok, f = skynet.response(skynet.pack( ... ))
	-- f()
	-- skynet.ret(skynet.pack( ... ))
	pack = function ( msg )
		-- body
		local str = crypt.desencode(secret, msg)
		return crypt.base64decode(str)
	end,
	unpack = function (msg, sz)
		if sz > 0 then 		
			return host:dispatch(msg, sz)
		elseif sz == 0 then
			return "HELLO"
		else
			assert(false)
		end
	end,
	dispatch = function (_,_, type, ...)
		if type == "REQUEST" then
			local ok, result = pcall(request, ...)
			if ok then
				if result then
					--send_package(result)
					skynet.ret(skynet.pack(result))
					--skynet.ret(result)
				end
			else
				assert(false)
				skynet.error("result")
				skynet.ret(skynet.pack("error"))
			end
		elseif type == "HELLO" then
			skynet.error "hello sz == 0"
		else	
			assert(type == "RESPONSE")
			error "this example doesn't support request client"
		end
	end
}

local gate
local userid, subid
local secret

local CMD = {}

function CMD.login(source, uid, sid, secret)
	-- you may use secret to make a encrypted data stream
	skynet.error(string.format("%s is login", uid))
	gate = source
	userid = uid
	subid = sid
	secret = secret
	-- you may load user data from database
	
end

local function logout()
	if gate then
		skynet.call(gate, "lua", "logout", userid, subid)
	end
	skynet.exit()
end

function CMD.logout(source)
	-- NOTICE: The logout MAY be reentry
	skynet.error(string.format("%s is logout", userid))
	logout()
end

function CMD.afk(source)
	-- the connection is broken, but the user may back
	skynet.error(string.format("AFK"))
end

function CMD.start(source, conf)
	print "msgagent cmd start"
	local fd = conf.client
	local gate = conf.gate
	--WATCHDOG = conf.watchdog
	-- slot 1,2 set at main.lua
	host = sprotoloader.load(1):host "package"  -- tag 1
	send_request = host:attach(sprotoloader.load(2)) -- tag 2
	-- skynet.fork(function ()
	-- 	while true do
	-- 		send_package(send_request "heartbeat")
	-- 		skynet.sleep(500)
	-- 	end
	-- end)
	-- client_fd = fd
	-- skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect()
	skynet.exit()
end

skynet.start(function()
	-- If you want to fork a work thread , you MUST do it in CMD.login
	skynet.dispatch("lua", function(session, source, command, ...)
		local f = assert(CMD[command])
		skynet.ret(skynet.pack(f(source, ...)))
	end)

	--skynet.dispatch("client", function(_,_, msg)
		-- the simple echo service
	--	skynet.sleep(10)	-- sleep a while
	--	skynet.ret(msg)
	--end)
end)
