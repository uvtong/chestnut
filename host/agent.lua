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

local game
local user

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

function REQUEST:account()
	-- body
	return 2, { errorcode = 0, msg = "ok"}
end

function REQUEST:enter_room()
	-- body
	print("enter_room", self.rule, self.mode)
	return 4, { errorcode=0, msg="ok"}
end

function REQUEST:handshake()
	return { msg = "Welcome to skynet, I will send heartbeat every 5 sec." }
end

function REQUEST:quit()
	skynet.call(WATCHDOG, "lua", "close", client_fd)
end

local function request(name, args, response)
	local f = assert(REQUEST[name])
	local tag, msg = f(args)
	if response then
		return response(tag, msg)
	end
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		if sz == 0 then
			return "HEARTBEAT"
		else	
			local code = skynet.tostring(msg, sz)
			local package = protobuf.decode(c2s_proto.package .. "." .. c2s_proto.message_type[1].name, string.sub(code, 1, 6))
			local msg = protobuf.decode(c2s_proto.package .. "." .. c2s_proto.message_type[package.tag+1].name, string.sub(code, 7))
			local function response(tag, msg)
				-- body
				local pg = {	
					tag = tag, -- client.
					type = "RESPONSE",
					session = package.session,
				}
				local code = protobuf.encode(c2s_proto.package .. "." .. c2s_proto.message_type[1].name, pg)
				local encode = protobuf.encode(c2s_proto.package .. "." .. c2s_proto.message_type[tag + 1].name, msg)
				return code .. encode
			end
			return package.type, string.gsub(c2s_proto.message_type[package.tag+1].name, "req_(%w*)", "%1"), msg, response
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
		elseif type == "HEARTBEAT" then
			send_package(send_request(2, { msg = "HEARTBEAT"}))
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
	
	local addr = io.open("../host/c2s.pb","rb")
	local buffer = addr:read "*a"
	addr:close()
	protobuf.register(buffer)
	t = protobuf.decode("google.protobuf.FileDescriptorSet", buffer)
	c2s_proto = t.file[1]
	print(c2s_proto.name)
	print(c2s_proto.package)

	addr = io.open("../host/s2c.pb","rb")
	buffer = addr:read "*a"
	addr:close()
	protobuf.register(buffer)
	t = protobuf.decode("google.protobuf.FileDescriptorSet", buffer)
	s2c_proto = t.file[1]
	print(s2c_proto.name)
	print(s2c_proto.package)

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
