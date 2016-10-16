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
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function REQUEST:enter_room(args, ... )
	-- body
	local rule = args.rule
	local mode = args.mode
	local scene = args.scene
	local uid = self:get_uid()
	local room = skynet.call(".ROOM_MGR", "lua", "enqueue", uid, rule, mode, scene)
	self:set_room(room)
	local res = skynet.call(room, "client", "enter_room", uid, skynet.self())
	assert(type(res) == "table")
	return res
end

function REQUEST:ready(args, ... )
	-- body
	local room = self:get_room()
	return skynet.call(room, "client", "ready", args)
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
	log.info("agent [%s] request", name)
    local f = REQUEST[name]
    local ok, result = pcall(f, ctx, args)
    if ok then
    	return response(result)
    else
    	log.error(result)
    end
end      

function RESPONSE:enter_room(args, ... )
	-- body
	local room = self:get_room()
	skynet.send(room, "client", "enter_room", args)
end

function RESPONSE:ready(args, ... )
	-- body
	local room = self:get_room()
	skynet.send(room, "client", "ready", args)
end

function RESPONSE:rob(args, ... )
	-- body
	local room = self:get_room()
	skynet.send(room, "client", "rob", args)
end

function RESPONSE:deal(args, ... )
	-- body
	local room = self:get_room()
	skynet.send(room, "client", "ready", args)
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
				log.error(result)
			end
		elseif type == "RESPONSE" then
			pcall(response, ...)
		else
			assert(false, result)
		end
	end
}

-- called by room
function CMD:enter_room(source, player, ... )
	-- body
	local players = {}
	table.insert(players, player)
	self:send_request("enter_room", { players=players })
	return { name = "xiaomiao" }
end

-- called by room
function CMD:ready(source, args, ... )
	-- body
	self:send_request("ready", args)
	return noret
end

-- login
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
	self:logout()
	local room = self:get_room()
	if room then
		skynet.call(room, "lua", "leave_room", uid)
		self:set_room(nil)
	end
	return true
end

-- others serverce disconnect
function CMD:afk(source)
	-- body
	local uid = self:get_uid()
	log.info("agent uid = %d) disconnect", uid)
	return true
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
