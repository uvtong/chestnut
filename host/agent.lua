package.path = "../host/lualib/?.lua;" .. package.path
package.cpath = "../host/luaclib/?.so;" .. package.cpath
local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local protobuf = require "protobuf"

local WATCHDOG
local host
local send_request

local CMD = {}
local REQUEST = {}
local client_fd
local c2s_proto
local s2c_proto

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
	unpack = function (msg, sz)
		local code = skynet.tostring(msg, sz)
		local decode = protobuf.decode(c2s_proto.package .. "." .. c2s_proto.message_type[1].name, string.sub(code, 1, 4))
		-- print(decode.tag)
		-- print(decode.type)
		-- print(decode.session)
		local msg = protobuf.decode(c2s_proto.package .. "." .. c2s_proto.message_type[decode.tag].name, string.sub(code, 5))
		local function response( msg )
			-- body
			local package = {
				tag = decode.tag + 1,
				type = "RESPONSE",
				session = decode.session,
			}
			local code = protobuf.encode("c2s.package", package)
			local encode = protobuf.encode(c2s_proto.package .. "." .. c2s_proto.message_type[decode.tag + 1].name, msg)
			return code .. encode
		end
		return decode.type, c2s_proto.message_type[decode.tag].name, msg, response
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
	-- host = sprotoloader.load(1):host "package"
	-- send_request = host:attach(sprotoloader.load(2))
	-- skynet.fork(function()
	-- 	while true do
	-- 		send_package(send_request "heartbeat")
	-- 		skynet.sleep(500)
	-- 	end
	-- end)
	
	local addr = io.open("../host/addressbook.pb","rb")
	local buffer = addr:read "*a"
	local addr:close()

	protobuf.register(buffer)

	t = protobuf.decode("google.protobuf.FileDescriptorSet", buffer)

	c2s_proto = t.file[1]

	print(c2s_proto.name)
	print(c2s_proto.package)

	send_request = function ( tag, msg )
		-- body
		local package = {
			tag = 2,
			type = "REQUEST",
			session = 4,
		}
		local code = protobuf.encode("s2c.package", package)
		local encode = protobuf.encode(c2s_proto.package .. "." .. s2c_proto.message_type[tag].name, msg)
		return code .. encode
	end
	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect()
	-- todo: do something before exit
	skynet.exit()
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
