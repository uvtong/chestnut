local snax = require "snax"
local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local sproto = require "sproto"
local context = require "agent.context"
local log = require "log"
local errorcode = require "errorcode"
local float = require "float"

local ctx
local roomkeeper

function response.login(source, uid, sid, secret)
	-- you may use secret to make a encrypted data stream
	roomkeeper = snax.queryservice "roomkeeper"
	log.info("agent %s is login", uid)
	
	ctx:login(source, uid, sid, secret)
	-- you may load user data from database
	return true
end

function response.logout()
	-- NOTICE: The logout MAY be reentry
	local uid = ctx:get_uid()
	snax.printf("%s is logout", uid)
	local room = ctx:get_room()
	if room then
		local session = ctx:get_session()
		room.req.leave(session, uid)
	end
	ctx:logout()
end

function response.afk(fd)
	-- the connection is broken, but the user may back
	snax.printf("AFK")
end

function accept.join(args, ... )
	-- body
	log.info("agent. join")
	ctx:send_request("join", args)
end

function accept.born(args, ... )
	-- body
	log.info("agent born")
	ctx:send_request("born", args)
end
function accept.addspeed(args, ... )
	-- body
	log.info("agent addspeed")
	ctx:send_request("addspeed", args)
end
function accept.movedriction(args, ... )
	-- body
	log.info("agent movedriction")
	ctx:send_request("movedriction", args)
end
function accept.leave(args, ... )
	-- body
	ctx:send_request("leave", args)
end

function accept.die(args, ... )
	-- body
	ctx:send_request("die", args)
end

function accept.hurt(args, ... )
	-- body
	ctx.send_request("hurt",args);
end
function accept.SendBuff(args, ... )
	-- body
	ctx.send_request("buff",args);
end

function accept.start(conf, ... )
	-- body
	local fd      = assert(conf.client)
	local version = assert(conf.version)
	local index   = assert(conf.index)
	local uid     = assert(conf.uid) 

	ctx:set_fd(fd)
	ctx:set_version(version)
	ctx:set_index(index)
end

local client_request = {}

function client_request.handshake( ... )
	-- body
	ctx:send_request("handshake")
	local res = { errorcode = 1 }
	return res
end

function client_request.join(msg)

	local secret = ctx:get_secret()
	local handle, host, port = roomkeeper.req.apply(msg.room)
	local room = snax.bind(handle , "room")
	ctx:set_room(room)
	local session, ps = room.req.join(skynet.self(), secret)
	ctx:set_session(session)
	return { session = session, host = host, port = port, players = ps }
end

function client_request.movedriction(msg, ... )
	-- body
	local session = ctx:get_session()
	local room = ctx:get_room()
	return room.req.movedriction(session, msg)
end

function client_request.born( ... )
	-- body
	local session = ctx:get_session()
	local room = ctx:get_room()
	return room.req.born(session)
end

function client_request.opcode(args, ... )
	-- body
	local session = ctx:get_session()
	local room = ctx:get_room()
	return room.req.opcode(session, args)
end
function client_request.addspeed(args, ... )
	-- body
	local session = ctx:get_session()
	local room = ctx:get_room()
	return room.req.addspeed(session, args)
end

local client_response = {}

function client_response.handshake(args, ... )
	-- body
	if args.errorcode == errorcode.SUCCESS then
		-- log.info("handshake SUCCESS")
	end
end

function client_response.join(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function client_response.born(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function client_response.leave(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function client_response.movedrirection(args,... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function client_response.opcode(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end
function client_response.movedriction(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end
function client_response.addspeed(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end
function client_response.die(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end
function client_response.hurt(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end
function client_response.Buff(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end
local function decode_proto(msg, sz, ... )
	-- body
	if sz > 0 then
		local host = ctx:get_host()
		return host:dispatch(msg, sz)
	elseif sz == 0 then
		return "HANDSHAKE"
	end
end

local function request(name, args, response)
	log.info("uid %d agent request: %s", ctx:get_uid(), name)
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
	log.info("uid %d agent response: %s", ctx:get_uid(), name)
    local f = client_response[name]
    local ok, result = pcall(f, args)
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
	elseif type == "HANDSHAKE" then
		-- log.info("handshake")
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
