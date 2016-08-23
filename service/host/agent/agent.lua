package.path = "./../../service/host/agent/?.lua;./../../service/host/lualib/?.lua;../../lualib/?.lua;"..package.path
local skynet = require "skynet"
local netpack = require "netpack"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local mc = require "multicast"
local dc = require "datacenter"
local util = require "util"
local const = require "const"
local context = require "context"
local log = require "log"
local errorcode = require "errorcode"
local assert = assert
local pcall = skynet.pcall
local error = skynet.error

local ctx       = context.new()
local CMD       = {}
local REQUEST   = {}
local RESPONSE  = {}
local SUBSCRIBE = {}

local function subscribe()
	-- body
	local u = env:get_user()
	local addr = skynet.self()
	local uid = u:get_uid()
	local c = skynet.call(".channel", "lua", "agent_start", uid, addr)
	local c2 = mc.new {
		channel = c,
		dispatch = function ( channel, source, cmd, args, ... )
			-- body
			local f = SUBSCRIBE[cmd]
			f(env, args)
		end
	}
	c2:subscribe()
end

function REQUEST.logout( ... )
	-- body
end

function REQUEST.login(source, uid, sid, secret, g, d)
	-- body
end

function REQUEST:enter_room( ... )
	-- body
	local addr = skynet.call(".ROOM_MGR", "lua", "enqueue")
	local conf = {}
	conf.client = self:get_fd()
	conf.gate = self:get_gate()
	conf.version = self:get_version()
	conf.index = self:get_index()
	skynet.call(addr, "lua", "join", conf)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function REQUEST:wake(args, ... )
	-- body
	local role_id = args.role_id
	error(role_id)
	local res = {}
	res.errorcode = 0
	return res
end

local function request(name, args, response)
	error(string.format("line request: %s", name))
    local f = REQUEST[name]
    local ok, result = pcall(f, ctx, args)
    if ok then
    	return response(result)
    else
    	error(result)
    	local ret = {}
    	ret.errorcode = errorcode.FAIL
    	return response(ret)
    end
end      

function RESPONSE:finish_achi( ... )
	-- body
	assert(self.errorcode == 1)
	skynet.error(self.msg)
end

local function response(session, args)
	-- body
	error(string.format("response: %s", name))
    local f = RESPONSE[name]
    local ok, result = pcall(f, env, args)
    if ok then
    else
    	skynet.error(result)
    end
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		if sz > 0 then
			local host = ctx:get_host()
			return host:dispatch(msg, sz)
		else 
			assert(false)
		end
	end,
	dispatch = function (session, source, type, ...)	
		if type == "REQUEST" then
			local ok, result = pcall(request, ...)
			if ok then
				if result then
					ctx:send_package(result)
				end
			else
				skynet.error(result)
			end
		elseif type == "RESPONSE" then
			pcall(response, ...)
		else
			assert(false, result)
		end
	end
}

function CMD:enter_room(source, room)
	-- body
	self.room = room
	self.rdtroom = true
	-- skynet.
	-- for k,v in pairs(t) do
	-- 	assert(room[k] == nil)
	-- 	room[k] = v
	-- 	send_package(send_request(2, { user_id=tonumber(k), name="hello" })) 
	-- end
end

function CMD:newemail(source, subcmd , ... )
	local f = assert( new_emailrequest[ subcmd ] )
	f( new_emailrequest , ... )
end

-- login
function CMD:login(source, uid, subid, secret,... )
	-- body
	self:login(uid, subid, secret)
	return true
end

-- prohibit mult landing
function CMD:logout(source)
	-- body
	skynet.error(string.format("%s is logout", userid))
	self:logout()
end

-- others serverce disconnect
function CMD:afk(source)
	-- body
	skynet.error(string.format("AFK"))
end

-- begain to wait for client
function CMD:start(source, conf)
	local fd      = assert(conf.client)
	local gate    = assert(conf.gate)
	local version = assert(conf.version)
	local index   = assert(conf.index)
	
	self:set_fd(fd)
	self:set_gate(gate)
	self:set_version(version)
	self:set_index(index)
	
	local uid = self:get_uid()
	-- skynet.call(gate, "lua", "forward", uid, skynet.self())
	return true
end

-- client disconnect, give handshake to gated
function CMD:disconnect()
	-- todo: do something before exit
	-- skynet.exit()
	log.info("disconnect")
end

function CMD:update_db( ... )
	-- body
	flush_db(const.DB_PRIORITY_3)
end

skynet.start(function()
	skynet.dispatch("lua", function(_, source, cmd, ...)
		error("agent is called", cmd)
		local f = assert(CMD[cmd])
		local result = f(ctx, source, ... )
		if result then
			skynet.ret(skynet.pack(result))
		end
	end)
	-- slot 1,2 set at main.lua
	local host = sprotoloader.load(1):host "package"
	local send_request = host:attach(sprotoloader.load(2))
	ctx:set_host(host)
	ctx:set_send_request(send_request)
end)
