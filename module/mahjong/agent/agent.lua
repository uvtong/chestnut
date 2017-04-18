package.path = "./../../module/mahjong/agent/?.lua;./../../module/mahjong/lualib/?.lua;../../lualib/?.lua;"..package.path
local skynet = require "skynet"
local netpack = require "netpack"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local mc = require "multicast"
local dc = require "datacenter"
local util = require "util"
local const = require "const"
local context = require "acontext"
local log = require "log"
local errorcode = require "errorcode"
local checkindaily = require "checkindaily"
local redis = require "redis"
local assert = assert
local pcall = skynet.pcall
local error = skynet.error
local noret = {}

local ctx       = false
local CMD       = {}
local REQUEST   = {}
local RESPONSE  = {}
local SUBSCRIBE = {}


local conf = {
	host = "127.0.0.1" ,
	port = 6379 ,
	db = 0
}

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

function REQUEST:logout( ... )
	-- body
	self:logout()
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function REQUEST:handshake(args, ... )
	-- body
	self:send_request("handshake")
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function REQUEST:create(args, ... )
	-- body
	local uid = self:get_uid()
	local sid = self:get_subid()
	local agent = skynet.self()
	local name = self._user.name.value
	local sex = self._user.sex.value
	local agent = {
		uid = uid,
		sid = sid,
		agent = agent,
		name = name,
		sex = sex
	}
	local id = skynet.call(".ROOM_MGR", "lua", "create", uid, args)
	local addr = skynet.call(".ROOM_MGR", "lua", "apply", id)
	self:set_room(addr)
	local res = skynet.call(addr, "lua", "on_create", agent)
	return res
end

function REQUEST:join(args, ... )
	-- body
	local res = {}
	local uid = self:get_uid()
	local sid = self:get_subid()
	local agent = skynet.self()
	local name = self._user.name.value
	local sex = self._user.sex.value
	local agent = {
		uid = uid,
		sid = sid,
		agent = agent,
		name = name,
		sex = sex
	}
	local addr = skynet.call(".ROOM_MGR", "lua", "apply", args.roomid)
	if addr and addr == 0 then
		res.errorcode = errorcode.NOEXiST_ROOMID
		return res
	else
		self:set_room(addr)
		local res = skynet.call(addr, "lua", "on_join", agent)
		return res
	end
end

function REQUEST:leave(args, ... )
	-- body
	if self:get_join() then
		local uid = self:get_uid()
		skynet.send(".ROOM_MGR", "lua", "dequeue_agent", uid)
	end
end

function REQUEST:first(args, ... )
	-- body
	return self:first()
end

function REQUEST:checkindaily(args, ... )
	-- body
	local res = {}
	local cds, day = util.cd_sec()
	if u.checkin_lday.value == cds then
		res.errorcode = errorcode.FAIL
		return res
	else
		local cnt = self._user.checkin_count.value
		cnt = cnt + 1
		self._user:set_checkin_count(cnt)
		self._user:update_db("tg_users", 7)
		local mcnt = set._user.checkin_mcount.value
		mcnt = mcnt + 1
		self._user:set_checkin_mcount(mcnt)
		self._user:update_db("tg_users", 8)
	end
	res.errorcode = errorcode.SUCCESS
	return res
end

function REQUEST:fetchsysmail(args, ... )
	-- body
	return self._sysinbox:fetch(args)
end

function REQUEST:syncsysmail(args, ... )
	-- body
	return self._sysinbox:sync(args)
end

function REQUEST:viewedsysmail(args, ... )
	-- body
	return self._sysinbox:viewed(args)
end

function REQUEST:records(args, ... )
	-- body
	return self._recordmgr:records(args)
end


local function room_request(name, args, ... )
	-- body
	local cmd = {}
	cmd["lead"] = true
	cmd["call"] = true
	cmd["shuffle"] = true
	cmd["dice"] = true
	cmd["step"] = true
	cmd["restart"] = true
	cmd["rchat"] = true
	cmd["xuanpao"] = true
	cmd['xuanque'] = true
	if cmd[name] then
		local addr = assert(ctx:get_room())
		local command = "on_"..name
		log.info("route request command %s agent to room", command)
		if addr then
			return skynet.call(addr, "lua", command, args)
		end
	end
	return false
end

local function request(name, args, response)
	-- log.info("agent request [%s]", name)
	local ok, result = pcall(room_request, name, args)
	if ok then
		if result then
			return response(result)
		end
	end
    local f = REQUEST[name]
    local msgh = function ( ... )
		-- body
		log.info(tostring(...))
		log.info(debug.traceback())
	end
    local ok, result = xpcall(f, msgh, ctx, args)
    if ok then
    	return response(result)
    end
end      

function RESPONSE:handshake(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function RESPONSE:join(args, ... )
	-- body
	local room = self:get_room()
	skynet.send(room, "lua", "join", args)
end

function RESPONSE:leave(args, ... )
	-- body
end

local function room_response(name, args)
	-- body
	assert(name)
	local cmd = {}
	cmd["deal"] = true
	cmd["ready"] = true
	cmd["take_turn"] = true
	cmd["peng"] = true
	cmd["gang"] = true
	cmd["hu"] = true
	cmd["call"] = true
	cmd["shuffle"] = true
	cmd["dice"] = true
	cmd["lead"] = true
	cmd["over"] = true
	cmd["restart"] = true
	cmd["rchat"] = true
	cmd["take_restart"] = true
	cmd["take_xuanpao"] = true
	cmd["take_xuanque"] = true
	cmd["xuanque"] = true
	cmd["xuanpao"] = true
	cmd["settle"] = true
	cmd["final_settle"] = true
	cmd["roomover"] = true
	if cmd[name] then
		local addr = ctx:get_room()
		skynet.send(addr, "lua", name, args)
		log.info("route response command %s agent to room", name)
		return true
	end
	return false
end

local function response(session, args)
	-- body
	local name = ctx:get_name_by_session(session)
	-- log.info("agent response [%s]", name)
	local ok, result = pcall(room_response, name, args)
	if ok then
		if result then
			return
		end
	end
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

function CMD:start( ... )
	-- body
	return true
end

function CMD:close( ... )
	-- body
	return true
end

function CMD:kill( ... )
	-- body
	skynet.exit()
	return noret
end

-- called by gated
function CMD:login(source, gate, uid, subid, secret,... )
	-- body
	local db = redis.connect(conf)
	self:set_db(db)

	self:login(gate, uid, subid, secret)

	skynet.send(".ONLINE_MGR", "lua", "login", self._uid)
	
	return true
end

-- prohibit mult landing
function CMD:logout(source)
	-- body
	local uid = self:get_uid()
	log.info("user %d logout", uid)
	local room = self:get_room()
	if room then
		local args = {}
		args.uid = uid
		skynet.call(room, "lua", "on_leave", args)
		self:set_room(nil)
	end
	self:logout()
	local db = self:get_db()
	db:disconnect()
	
	return true
end

-- others serverce disconnect
function CMD:afk(source)
	-- body
	local uid = self:get_uid()
	local sid = self:get_subid()

	if self:get_state() == context.state.ENTER_ROOM then
		skynet.call(".ROOM_MGR", "lua", "afk", uid)
	end

	if self:get_state() == context.state.ENTER_ROOMED then
		local addr = assert(self:get_room())
		skynet.call(addr, "lua", "afk", sid)
	end

	skynet.send(".ONLINE_MGR", "lua", "afk", self._user.name.value)

	return true
end

-- begain to wait for client
function CMD:authed(source, conf)

	log.info("authed")
	local fd      = assert(conf.client)
	local version = assert(conf.version)
	local index   = assert(conf.index)

	self:set_fd(fd)
	self:set_version(version)
	self:set_index(index)
	
	return true
end

function CMD:info(source, ... )
	-- body
	return { name="xiaomiao"}
end

function CMD:alter_rcard(source, num, ... )
	-- body
	local rcard = self._user.rcard.value + num
	self._user:set_rcard(rcard)
end

-- called by room
function CMD:join(source, args, ... )
	-- body
	self:send_request("join", args)
	return noret
end

function CMD:leave(source, args, ... )
	-- body
	self:send_request("leave", args)
	return noret
end

function CMD:room_over(source, ... )
	-- body
	self:set_room(nil)
end

function CMD:record(source, recordid, names, ... )
	-- body
	local r = self._recordmgr:create(recordid, names)
	self._recordmgr:add(r)
	r:insert_db()
end

local function room_sendrequest(name, args, ... )
	-- body
	assert(name)
	local cmd = {}
	cmd["deal"] = true
	cmd["ready"] = true
	cmd["take_turn"] = true
	cmd["peng"] = true
	cmd["gang"] = true
	cmd["hu"] = true
	cmd["call"] = true
	cmd["shuffle"] = true
	cmd["dice"] = true
	cmd["lead"] = true
	cmd["over"] = true
	cmd["restart"] = true
	cmd["take_restart"] = true
	cmd["rchat"] = true
	cmd["take_xuanpao"] = true
	cmd["take_xuanque"] = true
	cmd["xuanque"] = true
	cmd["xuanpao"] = true
	cmd["settle"] = true
	cmd["final_settle"] = true
	cmd["roomover"] = true
	if cmd[name] then
		ctx:send_request(name, args)
		return true
	end
	return false
end

skynet.start(function()
	skynet.dispatch("lua", function(_, source, cmd, ...)
		log.info("agent cmd [%s] is called", cmd)
		local ok, err = pcall(room_sendrequest, cmd, ...)
		if ok then
			if err then
				return
			end
		else
			log.error(err)
			return
		end
		local f = assert(CMD[cmd])
		local msgh = function ( ... )
			-- body
			log.info(tostring(...))
			log.info(debug.traceback())
		end
		local ok, err = xpcall(f, msgh, ctx, source, ...) 
		if ok then
			if err ~= noret then
				skynet.retpack(err)
			end
		end
	end)
	-- slot 1,2 set at main.lua
	init()
end)
