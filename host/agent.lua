package.path = "../host/lualib/?.lua;../host/?.lua;" .. package.path
package.cpath = "../host/luaclib/?.so;" .. package.cpath
local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local protobuf = require "protobuf"
local lpeg = require "lpeg"
local util = require "util"
local dc = require "datacenter"
local loader = require "loader"
local errorcode = require "errorcode"

local WATCHDOG
local host
local send_request

local CMD = {}
local REQUEST = {}
local RESPONSE = {}
local client_fd
local c2s_proto
local s2c_proto

local game
local user
local left
local right

local room = {}

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

function REQUEST:signup()
	-- body
	-- 0. success
	-- 1.
	local ret = {}
	local condition = { uaccount = self.account}
	local addr = util.random_db()
	local r = skynet.call(addr, "lua", "command", "signup", { condition } )
	if #r == 0 then
		local t = { csv_id=util.guid(game, const.UENTROPY), 
				uname="nihao", 
				uaccount=self.account, 
				upassword=self.password, 
				uviplevel=0,
				config_sound=1, 
				config_music=1, 
				avatar=0, 
				sign="peferct ", 
				c_role_id=1, 
				ifonline=0, 
				level=0, 
				combat=0, 
				defense=0, 
				critical_hit=0, 
				blessing=0, 
				modify_uname_count=0, 
				onlinetime=0, 
				iconid=0, 
				is_valid=1, 
				recharge_rmb=0, 
				goods_refresh_count=0, 
				recharge_diamond=0, 
				uvip_progress=0, 
				checkin_num=0, 
				checkin_reward_num=0, 
				exercise_level=0, 
				cgold_level=0 }
		local usersmgr = require "models/usersmgr"
		local u = usersmgr.create(t)
		u:__insert_db()
		ret.errorcode = 0
		ret.msg = "success"
		return ret
	end
end

function REQUEST:account()
	-- body
	assert(self.account ~= "hubing")
	assert(self.password ~= "123456")
	local addr = util.random_db()
	-- local r = skynet.call(addr, "command", "select", "users", {{ account=self.account, password=self.password }})
	if r and #r == 1 then
		local users = require "models/usersmgr"
		user = users.create(r)
		dc.set(user.csv_id, { addr=skynet.self(), client_fd=client_fd })
		return { errorcode=0, msg="yes"}
	end
	return { errorcode = 1, msg = "no"}
end

function REQUEST:logout( ... )
	-- body
	local ret = {}
	ret.errorcode = 0
	ret.msg = "success"
	return ret
end

function REQUEST:enter_room()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode.OFFLINE.errorcode
		ret.msg = errorcode.OFFLINE.msg	
		return ret
	end
	self.user_id = user.csv_id
	local r = skynet.call(".scene", "lua", "enter_room", self)
	if r.c.name == "left" then
		left = {}
		left.user_id = r.user_id
		left.addr = r.addr
	elseif r.name == "right" then
		right = {}
		right.user_id = r.user_id
		right.addr = r.addr
	end
	ret.errorcode = errorcode.SUCCESS.errorcode
	ret.msg = errorcode.SUCCESS.msg
	return { errorcode=0, msg="ok"}
end

function REQUEST:ready()
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode.OFFLINE.errorcode
		ret.msg = errorcode.OFFLINE.msg
		return ret
	end
	assert(user)
	user.ready = self.ready
	self.user_id = user.csv_id
	skynet.send(left.addr, "lua", "ready", self)
	skynet.send(right.addr, "lua", "ready", self)
	ret.errorcode = errorcode.SUCCESS.errorcode
	ret.msg = errorcode.SUCCESS.msg
	return ret
end

function REQUEST:mp()
	-- body
end

function REQUEST:am()
	-- body
end

function REQUEST:rob()
	-- body
	skynet.send(right.addr, "lua", "left.user_id", self.m)
end

function REQUEST:lead()
	-- body
end

function REQUEST:handshake()
	return { msg = "Welcome to skynet, I will send heartbeat every 5 sec." }
end

function REQUEST:quit()
	skynet.call(WATCHDOG, "lua", "close", client_fd)
end

local function request(name, args, response)
	local f = assert(REQUEST[name])
	print("REQUEST:", name)
	local msg = f(args)
	if response then
		return response(msg)
	end
end

function RESPONSE:enter_room()
	-- body
	assert(self.errorcode == 0)
end

function RESPONSE:ready()
	-- body
	assert(self.errorcode == 0)
end

function RESPONSE:mp()
	-- body
end

function RESPONSE:deal_cards()
	-- body
end

function RESPONSE:rob()
	-- body
end

function RESPONSE:turn_rob()
	-- body
end

function RESPONSE:mark()
	-- body
end

function RESPONSE:lead()
	-- body
end

function RESPONSE:turn_lead()
	-- body
end

local function response(name, args)
	-- body
	local f = assert(RESPONSE[name])
	f(args)
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
			if package.type == "REQUEST" then
				local args = protobuf.decode(c2s_proto.package .. "." .. c2s_proto.message_type[package.tag+1].name, string.sub(code, 7))
				local function response(msg)
					-- body
					local pg = {	
						tag = package.tag + 1, -- client.
						type = "RESPONSE",
						session = package.session,
					}
					local pg_encode = protobuf.encode(c2s_proto.package .. "." .. c2s_proto.message_type[1].name, pg)
					local msg_encode = protobuf.encode(c2s_proto.package .. "." .. c2s_proto.message_type[pg.tag + 1].name, msg)
					return pg_encode .. msg_encode
				end
				return package.type, string.gsub(c2s_proto.message_type[package.tag+1].name, "req_(%w*)", "%1"), args, response
			elseif package.type == "RESPONSE" then
				local args = protobuf.decode(s2c_proto.package .. "." .. s2c_proto.message_type[package.tag+1].name, string.sub(code, 7))
				return package.type, string.gsub(s2c_proto.message_type[package.tag+1].name, "resp_(%w*)", "%1"), args
			else
				assert(false)
			end
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
		elseif type == "RESPONSE" then
			pcall(response, ...)
			-- assert(type == "RESPONSE")
			-- error "This example doesn't support request client"
		end
	end
}

function CMD.enter_room(t)
	-- body
	for k,v in pairs(t) do
		assert(room[k] == nil)
		room[k] = v
		send_package(send_request(2, { user_id=tonumber(k), name="hello" })) 
	end
end

function CMD.ready(t)
	-- body
	room.users[tostring(t.user_id)].ready = t.ready
	send_package(send_request(4, { user_id=user_id, ready=ready}))
end

function CMD.rob(user_id, m)
	-- body
	left.rob = m
	-- turn rob
	send_package(send_request(12, {user_id=user.csv_id, countdown=20}))
end

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

	local session = 1
	send_request = function ( tag, msg )
		-- body
		session = session + 1
		local package = {
			tag = tag,
			type = "REQUEST",
			session = session,
		}
		local code = protobuf.encode("s2c.package", package)
		local encode = protobuf.encode(s2c_proto.package .. "." .. s2c_proto.message_type[tag].name, msg)
		return code .. encode
	end
	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)

	game = loader.load_game()
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
