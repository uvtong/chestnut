package.cpath = "luaclib/?.so"
package.path = "lualib/?.lua;../cat/?.lua"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local socket = require "clientsocket"
local proto = require "proto"
local sproto = require "sproto"

local host = sproto.new(proto.s2c):host "package"
local request = host:attach(sproto.new(proto.c2s))

local fd = assert(socket.connect("127.0.0.1", 8888))

local function send_package(fd, pack)
	local package = string.pack(">s2", pack)
	socket.send(fd, package)
end

local function unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end

local function recv_package(last)
	local result
	result, last = unpack_package(last)
	if result then
		return result, last
	end
	local r = socket.recv(fd)
	if not r then
		return nil, last
	end
	if r == "" then
		error "Server closed"
	end
	return unpack_package(last .. r)
end

local session = 0

local function send_request(name, args)
	session = session + 1
	local str = request(name, args, session)
	send_package(fd, str)
	print("Request:", session)
end

local last = ""

local function print_request(name, args)
	print("REQUEST", name)
	if args then
		for k,v in pairs(args) do
			print(k,v)
		end
	end
end

local function print_response(session, args)
	print("RESPONSE", session)
	if args then
		for k,v in pairs(args) do
			if type(v) == "table" then
				for kk,vv in pairs(v) do
					print(kk,vv)
				end
			else
				print(k,v)
			end
		end
	end
end

local function print_package(t, ...)
	if t == "REQUEST" then
		print_request(...)
	else
		assert(t == "RESPONSE")
		print_response(...)
	end
end

local REQUEST = {}

function REQUEST:finish_achi( ... )
	-- body
	local ret = {}
	ret.errorcode = 0
	ret.msg = "yes"
	return ret
end

local function request(name, args, response)
	print( "request name :" .. name)
	for k,v in pairs(args) do
		print(k,v)
	end
	print(response)
    local f = assert(REQUEST[name])
    local r = f(args)

    if response then
    	print "hakldjfalfj"
    	return response(r)
    end               
end      

local function dispatch( type, ... )
	-- body
	if type == "REQUEST" then
		local ok, result  = pcall(request, ...)
		if ok then
			print "kaljlfajflajlf"
			if result then
				print "kajflajfldajf"
				send_package(result)
			end
		else
			error(result)
		end
	else
		assert(type == "RESPONSE")
		print_package(type, ...)
	end
end

local function dispatch_package()
	while true do
		local v
		v, last = recv_package(last)
		if not v then
			break
		end
		dispatch(host:dispatch(v))
	end
end

while true do
	dispatch_package()
	local cmd = socket.readstdin()
	if cmd then
		if cmd == "handshake" then
			send_request(cmd)
		elseif cmd == "role" then
			send_request(cmd)
		elseif cmd == "upgrade" then
			send_request(cmd, { role_id = 2 })
		elseif cmd == "choose_role" then
			send_request(cmd, { role_id = 2 })
		elseif cmd == "wake" then
			send_request(cmd, { role_id = 2 })
		elseif cmd == "props" then
			send_request(cmd)
		elseif cmd == "use_prop" then
			send_request(cmd, { props = {{ csv_id = 1, num = 1}}, role_id = 2})
		elseif cmd == "achievement" then
			send_request(cmd)
		elseif cmd == "channel" then
			send_request(cmd)
		elseif cmd == "login" then
			send_request("login", { account = "hello" , password = "world" })
		elseif cmd == "user_can_modify_name" then
			send_request("user_can_modify_name")
		elseif cmd == "user_modify_name" then
			send_request("user_modify_name", { name = "wahah"})
		elseif cmd == "user" then
			send_request("user")
		elseif cmd == "user_upgrade" then
			send_request("user_upgrade")
		else
			assert(false)
		end
	else
		socket.usleep(100)
	end
end
