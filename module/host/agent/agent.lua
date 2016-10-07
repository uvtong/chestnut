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
local noret = {}

local ctx       = false
local CMD       = {}
local REQUEST   = {}
local RESPONSE  = {}
local SUBSCRIBE = {}

local function init( ... )
	-- body
	local host = sprotoloader.load(1):host "package"
	local send_request = host:attach(sprotoloader.load(2))
	ctx = context.new()
	ctx:set_host(host)
	ctx:set_send_request(send_request)
end

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
	assert(false)
end

function REQUEST:enter_scene(args, ... )
	-- body
	local uid = self:get_uid()
	log.info("agent (uid = %d) request : enter_scene", uid)
	local rule = args.rule
	local mode = args.mode
	local scene = args.scene
	local uid = self:get_uid()
	local room = skynet.call(".ROOM_MGR", "lua", "enqueue", uid, rule, mode, scene)
	assert(room.size <= 3)
	self:set_room(room)
	
	local roomid = room.roomid
	local conf = {
		uid     = self:get_uid()
	}
	return skynet.call(roomid, "lua", "enter_room", conf)
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

function REQUEST:ready(args, ... )
	-- body
	local room = self:get_room()
	return skynet.call(room.roomid, "client", "ready", args)
end

function REQUEST:mp(args, ... )
	-- body
	local room = self:get_room()
	return skynet.call(room.roomid, "client", "mp", args)
end

function REQUEST:am(args, ... )
	-- body
	local room = self:get_room()
	return skynet.call(room.roomid, "client", "am", args)
end

function REQUEST:rob(args, ... )
	-- body
	local room = self:get_room()
	return skynet.call(room.roomid, "client", "rob", args)
end

function REQUEST:lead(args, ... )
	-- body
	local room = self:get_room()
	return skynet.call(room.roomid, "client", "lead", args)
end

local function request(name, args, response)
	log.info("agent request: %s", name)
    local f = REQUEST[name]
    local ok, result = pcall(f, ctx, args)
    if ok then
    	return response(result)
    else
    	log.error(result)
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

function RESPONSE:deal(args, ... )
	-- body
	local room = self:get_room()
	local roomid = roomid
	skynet.send(roomid, "client", "RESPONSE", name, args)
end

local function response(session, args)
	-- body
	local name = ctx:get_name_by_session(session)
	log.info("room response: %s", name)
    local f = RESPONSE[name]
    local ok, result = pcall(f, ctx, args)
    if ok then
    else
    	log.error(result)
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

-- push new player to client.
function CMD:enter_room(source, player, ... )
	-- body
	local players = {}
	table.insert(players, player)
	self:send_request("enter_room", players)
	local res = {}
	res.name = "hello"
	return res
end

function CMD:ready(source, args, ... )
	-- body
	self:send_request("ready", args)
	return noret
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
	log.info("agent uid = %d) disconnect", uid)
end

-- begain to wait for client
function CMD:start(source, conf)
	local uid = self:get_uid()
	log.info("agent (uid = %d) start", uid)
	local fd      = assert(conf.client)
	local gate    = assert(conf.gate)
	local version = assert(conf.version)
	local index   = assert(conf.index)
	local uid     = assert(conf.uid) 

	self:set_fd(fd)
	self:set_gate(gate)
	self:set_version(version)
	self:set_index(index)

	-- skynet.call(gate, "lua", "forward", uid, skynet.self())
	return true
end

function CMD:send_request(name, args, ... )
	-- body
	self:send_request(name, args)
end

function CMD:update_db( ... )
	-- body
	flush_db(const.DB_PRIORITY_3)
end

skynet.start(function()
	skynet.dispatch("lua", function(_, source, cmd, ...)
		log.info("agent is called: %s", cmd)
		local f = assert(CMD[cmd])
		local result = f(ctx, source, ... )
		if result ~= noret then
			assert(result)
			skynet.ret(skynet.pack(result))
		end
	end)
	-- slot 1,2 set at main.lua
	init()
end)