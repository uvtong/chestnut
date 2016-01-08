package.cpath = "luaclib/?.so"
package.path = "lualib/?.lua;../crazy/?.lua"

local socket = require "clientsocket"
local crypt = require "crypt"
local proto = require "proto"
local sproto = require "sproto"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local fd = assert(socket.connect("127.0.0.1", 8001))

local function writeline(fd, text)
	socket.send(fd, text .. "\n")
end

local function unpack_line(text)
	local from = text:find("\n", 1, true)
	if from then
		return text:sub(1, from-1), text:sub(from+1)
	end
	return nil, text
end

local last = ""

local function unpack_f(f)
	local function try_recv(fd, last)
		local result
		result, last = f(last)
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
		return f(last .. r)
	end

	return function()
		while true do
			local result
			result, last = try_recv(fd, last)
			if result then
				return result
			end
			socket.usleep(100)
		end
	end
end

local readline = unpack_f(unpack_line)
-- 0
--local cha = crypt.base64decode(readline())
print(readline())

-- 1. get challenge
local challenge = crypt.base64decode(readline())

-- 2. generate clientkey
local clientkey = crypt.randomkey()

-- 3. send clientkey to server
writeline(fd, crypt.base64encode(crypt.dhexchange(clientkey)))

-- 4. achieve secret.

local secret = crypt.dhsecret(crypt.base64decode(readline()), clientkey)

print("sceret is ", crypt.hexencode(secret))

-- 5. check secret.
local hmac = crypt.hmac64(challenge, secret)
writeline(fd, crypt.base64encode(hmac))

-- 6. (optionl) readline server
-- 
-- writeline(fd, "get_servers")
-- local proto = [[
-- 	.server {
-- 		.node {
-- 			name 0 : string
-- 			address 1 : string
-- 		}
-- 		nodes 0 : *node
-- 	}
-- ]]
-- local sp = sproto.parse(proto)
-- local servers = sp:decode("server", readline())
-- for k,v in pairs(servers) do
-- 	print(k,v)
-- end
--print(readline())

local token = {
	server = "sample",
	user = "hello",
	pass = "password",
}

local function encode_token(token)
	return string.format("%s@%s:%s",
		crypt.base64encode(token.user),
		crypt.base64encode(token.server),
		crypt.base64encode(token.pass))
end

local etoken = crypt.desencode(secret, encode_token(token))
local b = crypt.base64encode(etoken)

-- 7. auth
writeline(fd, crypt.base64encode(etoken))

local result = readline()
print(result)
local code = tonumber(string.sub(result, 1, 3))
assert(code == 200)
socket.close(fd)

-- 8. subid
local subid = crypt.base64decode(string.sub(result, 5))

print("login ok, subid=", subid)

----- connect to game server

local host = sproto.new(proto.s2c):host "package"
local request = host:attach(sproto.new(proto.c2s))

--local function send_package(fd, pack)
--	local package = string.pack(">s2", pack)
--	socket.send(fd, package)
--end

local function send_request_b(v, session)
	local size = #v + 4
	local package = string.pack(">I2", size)..v..string.pack(">I4", session)
	socket.send(fd, package)
	return v, session
end

local function recv_response(v)
	local size = #v - 5
	local content, ok, session = string.unpack("c"..tostring(size).."B>I4", v)
	return ok ~=0 , content, session
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

local readpackage = unpack_f(unpack_package)

local function send_package(fd, pack)
	local package = string.pack(">s2", pack)
	socket.send(fd, package)
end

local session = 0

local function send_request(name, args)
	session = session + 1
	local str = request(name, args, session)
	-- str = crypt.desencode(secret, str)
	-- str = crypt.base64encode(str)
	--send_package(fd, str)
	send_request_b(str, session)
	print("Request:", session)
end

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

local function dispatch_package()
	while true do
		local v
		v, last = recv_package(last)
		if not v then
			break
		end
		local ok, content, session = recv_response(v)
		print(ok, session)
		if ok then
			local str = crypt.base64decode(content)
			str = crypt.desdecode(secret, str)
			print_package(host:dispatch(str))
		end
	end
end

--local text = "echo"
local index = 1

print("connect")
fd = assert(socket.connect("127.0.0.1", 8888))
last = ""

local handshake = string.format("%s@%s#%s:%d", crypt.base64encode(token.user), crypt.base64encode(token.server),crypt.base64encode(subid) , index)
local hmac = crypt.hmac64(crypt.hashkey(handshake), secret)

-- send handshake
send_package(fd, handshake .. ":" .. crypt.base64encode(hmac))

print(readpackage())
send_request("handshake")
send_request("set", { what = "hello", value="world" })
while true do
	dispatch_package()
	local cmd = socket.readstdin()
	if cmd then
		if cmd == "quit" then
			send_request("quit")
		else
			send_request("get", { what = cmd })
		end
	else
		socket.usleep(100)
	end
end

--print(readpackage())
--print("===>",send_request(text,0))
-- don't recv response
-- print("<===",recv_response(readpackage()))

print("disconnect")
socket.close(fd)

--index = index + 1

--print("connect again")
--fd = assert(socket.connect("127.0.0.1", 8888))
--last = ""

--local handshake = string.format("%s@%s#%s:%d", crypt.base64encode(token.user), crypt.base64encode(token.server),crypt.base64encode(subid) , index)
--local hmac = crypt.hmac64(crypt.hashkey(handshake), secret)

--send_package(fd, handshake .. ":" .. crypt.base64encode(hmac))



--print(readpackage())
--print("===>",send_request("fake",0))	-- request again (use last session 0, so the request message is fake)
--print("===>",send_request("again",1))	-- request again (use new session)
--print("<===",recv_response(readpackage()))
--print("<===",recv_response(readpackage()))


--print("disconnect")
--socket.close(fd)

