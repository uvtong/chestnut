local snax = require "snax"
local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local sproto = require "sproto"
local context = require "agent.context"
local log = require "log"
local errorcode = require "errorcode"

local ctx
local roomkeeper

function response.login(source, uid, sid, secret)
	-- you may use secret to make a encrypted data stream
	roomkeeper = snax.queryservice "roomkeeper"
	log.info("agent %s is login", uid)
	
	ctx:login(uid, sid, secret)
	ctx:set_gate(source)
	-- you may load user data from database
	return true
end

local function logout()
	if gate then
		local userid = ctx:get_uid()
		local subid = ctx:get_subid()
		skynet.call(gate, "lua", "logout", U.userid, U.subid)
	end
	snax.exit()
end

function response.logout()
	-- NOTICE: The logout MAY be reentry
	snax.printf("%s is logout", U.userid)
	if room then
		room.req.leave(U.session)
	end
	logout()
end

function response.afk()
	-- the connection is broken, but the user may back
	snax.printf("AFK")
end

function accept.start(conf, ... )
	-- body
	local fd      = assert(conf.client)
	local gate    = assert(conf.gate)
	local version = assert(conf.version)
	local index   = assert(conf.index)
	local uid     = assert(conf.uid) 

	ctx:set_fd(fd)
	ctx:set_gate(gate)
	ctx:set_version(version)
	ctx:set_index(index)
end



local client_request = {}

function client_request.join(msg)
	local uid = ctx:get_uid()
	local secret = ctx:get_secret()
	skynet.error(uid, "client_request.join")
	local handle, host, port = roomkeeper.req.apply(msg.room)
	local r = snax.bind(handle , "room")
	local session = assert(r.req.join(skynet.self(), secret))
	ctx:set_session(session)
	ctx:set_room(r)
	return { session = session, host = host, port = port }
end

function client_request.handshake( ... )
	-- body
	local res = { errorcode = 1 }
	return res
end

local client_response = {}

local function decode_proto(msg, sz, ... )
	-- body
	if sz > 0 then
		local host = ctx:get_host()
		return host:dispatch(msg, sz)
	end
end

local function request(name, args, response)
	log.info("agent request: %s", name)
    local f = client_request[name]
    local ok, result = pcall(f, args)
    if ok then
    	return response(result)
    else
    	log.error(result)
    	local ret = {}
    	ret.errorcode = errorcode.FAIL
    	return response(ret)
    end
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

local function dispatch_client(_,_, type, ... )
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
	end
end

function init()
	skynet.register_protocol {
		name = "client",
		id = skynet.PTYPE_CLIENT,
		unpack = decode_proto,
	}

	-- todo: dispatch client message
	skynet.dispatch("client", dispatch_client)

	local host = sprotoloader.load(1):host "package"
	local send_request = host:attach(sprotoloader.load(2))
	ctx = context.new()
	ctx:set_host(host)
	ctx:set_send_request(send_request)
end