package.cpath = "luaclib/?.so;../host/luaclib/?.so"
package.path = "lualib/?.lua;../host/?.lua;../host/lualib/?.lua"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local socket = require "clientsocket"
local proto = require "proto"
local sproto = require "sproto"
local protobuf = require "protobuf"
local host = {}
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

function host:dispatch(code)
	-- body
	local package = protobuf.decode(c2s_proto.package .. "." .. c2s_proto.message_type[1].name, string.sub(code, 1, 6))
	if package.type == "REQUEST" then
		local args = protobuf.decode(c2s_proto.package .. "." .. c2s_proto.message_type[package.tag+1].name, string.sub(code, 7))
		local function response(msg)
			-- body
			local pg = {	
				tag = package.tag + 1, -- client.
				type = "RESPONSE",
				session = package.session,
			}
			local pg_encode = protobuf.encode(s2c_proto.package .. "." .. s2c_proto.message_type[1].name, pg)
			local msg_encode = protobuf.encode(s2c_proto.package .. "." .. s2c_proto.message_type[pg.tag + 1].name, msg)
			return pg_encode .. msg_encode
		end
		return package.type, string.gsub(c2s_proto.message_type[package.tag+1].name, "req_(%w*)", "%1"), args, response
	elseif package.type == "RESPONSE" then
		local args = protobuf.decode(c2s_proto.package .. "." .. c2s_proto.message_type[package.tag+1].name, string.sub(code, 7))
		return package.type, string.gsub(c2s_proto.message_type[package.tag+1].name, "resp_(%w*)", "%1"), args
	else
		assert(false)
	end
end

local request = function ( tag, args, session )
	-- body
	local package = {
		tag = tag,
		type = "REQUEST",
		session = session,
	}
	local code = protobuf.encode("c2s.package", package)
	print(tag+1)
	local encode = protobuf.encode(c2s_proto.package .. "." .. c2s_proto.message_type[tag+1].name, args)
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
			send_request(1, { account="end1", password="end1"})
		elseif cmd == "logout" then
			send_request(15, {})
		elseif cmd == "enter_room" then
			send_request(15, {})
		end
	else
		socket.usleep(100)
	end
end
