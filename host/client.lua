package.cpath = "luaclib/?.so"
package.path = "lualib/?.lua;../host/?.lua;../host/lualib/?.lua;../host/luaclib/?.lua"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local socket = require "clientsocket"
local proto = require "proto"
local sproto = require "sproto"
local protobuf = require "protobuf"

-- local host = sproto.new(proto.s2c):host "package"
-- local request = host:attach(sproto.new(proto.c2s))

local addr = io.open("../host/c2s.pb","rb")
local buffer = addr:read "*a"
addr:close()
protobuf.register(buffer)
local t = protobuf.decode("google.protobuf.FileDescriptorSet", buffer)
local c2s_proto = t.file[1]
print(c2s_proto.name)
print(c2s_proto.package)

addr = io.open("../host/s2c.pb","rb")
buffer = addr:read "*a"
addr:close()
protobuf.register(buffer)
t = protobuf.decode("google.protobuf.FileDescriptorSet", buffer)
local s2c_proto = t.file[1]
print(s2c_proto.name)
print(s2c_proto.package)

local request = function ( tag, args, session )
	-- body
	session = session + 1
	local package = {
		tag = tag,
		type = "REQUEST",
		session = session,
	}
	local code = protobuf.encode("c2s.package", package)
	local encode = protobuf.encode(c2s_proto.package .. "." .. s2c_proto.message_type[tag].name, args)
	return code .. encode
end

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
			print(k,v)
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
    local f = assert(REQUEST[name])
    local r = f(args)
    if response then
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
		print("print:", cmd)
		if cmd == "handshake" then
			assert(false)
		elseif cmd == "account" then
			send_request(2, { account="end1", password="end1"})
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
		end
	else
		socket.usleep(100)
	end
end
