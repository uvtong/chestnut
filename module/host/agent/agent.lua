package.path = "./../../module/host/agent/?.lua;./../../module/host/lualib/?.lua;../../lualib/?.lua;"..package.path
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

function REQUEST:handshake(args, ... )
	-- body
	self:send_request("handshake")
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function REQUEST:enter_room(args, ... )
	-- body
	self:set_onroom(true)
	local rule = args.rule
	local mode = args.mode
	local scene = args.scene
	local uid = self:get_uid()
	skynet.send(".ROOM_MGR", "lua", "enqueue_agent", uid, rule, mode, scene)
	local res = { errorcode = errorcode.SUCCESS}
	return res
end

function REQUEST:leave_room(args, ... )
	-- body
	local uid = self:get_uid()
	local room = self:get_room()
	skynet.send(".ROOM_MGR", "lua", "dequeue_agent", uid)
	local res = { errorcode = errorcode.SUCCESS}
	return res
end

function REQUEST:ready(args, ... )
	-- body
	local room = self:get_room()
	return skynet.call(room, "client", "on_ready", args)
end

function REQUEST:mp(args, ... )
	-- body
	local room = self:get_room()
	return skynet.call(room.roomid, "client", "on_mp", args)
end

function REQUEST:am(args, ... )
	-- body
	local room = self:get_room()
	return skynet.call(room.roomid, "client", "on_am", args)
end

function REQUEST:rob(args, ... )
	-- body
	local room = self:get_room()
	return skynet.call(room, "client", "on_rob", args)
end

function REQUEST:lead(args, ... )
	-- body
	local room = self:get_room()
	return skynet.call(room, "client", "lead", args)
end

local function request(name, args, response)
	log.info("agent request [%s]", name)
    local f = REQUEST[name]
    local ok, result = pcall(f, ctx, args)
    if ok then
    	return response(result)
    else
    	log.error(result)
    end
end      

function RESPONSE:handshake(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function RESPONSE:enter_room(args, ... )
	-- body
	local room = self:get_room()
	skynet.send(room, "lua", "enter_room", args)
end

function RESPONSE:ready(args, ... )
	-- body
	local room = self:get_room()
	skynet.send(room, "lua", "ready", args)
end

function RESPONSE:rob(args, ... )
	-- body
	local room = self:get_room()
	skynet.send(room, "lua", "rob", args)
end

function RESPONSE:deal(args, ... )
	-- body
	local room = self:get_room()
	skynet.send(room, "lua", "ready", args)
end

local function response(session, args)
	-- body
	local name = ctx:get_name_by_session(session)
	log.info("agent response [%s]", name)
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
				log.error(result)
			end
		elseif type == "RESPONSE" then
			pcall(response, ...)
		else
			assert(false, result)
		end
	end
}


-- called by gated
function CMD:login(source, uid, subid, secret,... )
	-- body
	self:login(source, uid, subid, secret)
	return true
end

-- prohibit mult landing
function CMD:logout(source)
	-- body
	local uid = self:get_uid()
	log.info("user %d logout", uid)
	local room = self:get_room()
	if room then
		skynet.call(room, "lua", "leave_room", uid)
		self:set_room(nil)
	end
	self:logout()
	return true
end

-- others serverce disconnect
function CMD:afk(source)
	-- body
	local uid = self:get_uid()
	log.info("agent uid = %d) disconnect", uid)
	return true
end

function CMD:info(source, ... )
	-- body
	return { name="xiaomiao"}
end

-- called by room
function CMD:enter_room(source, args, ... )
	-- body
	self:send_request("enter_room", args)
	return noret
end

function CMD:leave_room(source, ... )
	-- body
	self:set_onroom(false)
	self:set_room(nil)
end

-- called by room
function CMD:ready(source, args, ... )
	-- body
	self:send_request("ready", args)
	return noret
end

-- begain to wait for client
function CMD:start(source, conf)
	local fd      = assert(conf.client)
	local version = assert(conf.version)
	local index   = assert(conf.index)
	local uid     = assert(conf.uid) 

	self:set_fd(fd)
	self:set_version(version)
	self:set_index(index)

	-- skynet.call(gate, "lua", "forward", uid, skynet.self())
	return true
end

function CMD:update_db( ... )
	-- body
	flush_db(const.DB_PRIORITY_3)
end

skynet.start(function()
	skynet.dispatch("lua", function(_, source, cmd, ...)
		log.info("agent [%s] is called", cmd)
		local f = assert(CMD[cmd])
		local ok, err = pcall(f, ctx, source, ...) 
		if ok then
			if err ~= noret then
				skynet.retpack(err)
			end
		else
			log.error(err)
		end
	end)
	-- slot 1,2 set at main.lua
	init()
end)
