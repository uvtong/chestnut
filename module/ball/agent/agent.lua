package.path = "./../../module/ball/agent/?.lua;./../../module/ball/lualib/?.lua;../../lualib/?.lua;"..package.path
local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local sproto = require "sproto"
local context = require "agent.acontext"
local log = require "log"
local errorcode = require "errorcode"
local float = require "float"

local ctx

local cmd = {}

function cmd.newborn(source, uid, sid, secret, ... )
	-- body
	ctx:newborn(source, uid, sid, secret)
	return true
end

function cmd.login(source, uid, sid, secret)
	-- you may use secret to make a encrypted data stream
	local res = skynet.call(".UID_MGR", "lua", "login", uid)
	if res.new then
		ctx:newborn(source, uid, sid, secret, res.id)
	else
		ctx:login(source, uid, sid, secret, res.id)
	end
	-- you may load user data from database
	return true
end

function cmd.logout()
	-- NOTICE: The logout MAY be reentry
	local uid = ctx:get_uid()
	local room = ctx:get_room()
	if room then
		local session = ctx:get_session()
		room.req.leave(session, uid)
	end
	ctx:logout()
	log.info("uid: %d, suid: %d, is logout", uid, ctx:get_suid())
	return true
end

function cmd.afk()
	-- the connection is broken, but the user may back
	log.info("afk")
end

function cmd.authed(conf, ... )
	-- body
	local fd      = assert(conf.client)
	local version = assert(conf.version)
	local index   = assert(conf.index)
	
	ctx:set_fd(fd)
	ctx:set_version(version)
	ctx:set_index(index)
	return true
end

function cmd.match(args, ... )
	-- body
	ctx:send_request("match", args)
end

function cmd.join(args, ... )
	-- body
	log.info("agent. join")
	ctx:send_request("join", args)
end

function cmd.born(args, ... )
	-- body
	log.info("agent born")
	ctx:send_request("born", args)
end

function cmd.leave(args, ... )
	-- body
	ctx:send_request("leave", args)
end

function cmd.die(args, ... )
	-- body
	ctx:send_request("die", args)
end

function cmd.hurt(args, ... )
	-- body
	ctx.send_request("hurt",args);
end

local client_request = {}

function client_request.handshake( ... )
	-- body
	-- ctx:send_request("handshake")
	local res = { errorcode = 1 }
	return res
end

function client_request.join(args)

	local secret = ctx:get_secret()
	local room = skynet.call(".ROOM_MGR", "lua", "apply", args.roomid)
	ctx:set_room(room)

	local res = skynet.call(room, "lua", "join", skynet.self(), secret)
	ctx:set_session(res.session)

	return res
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

function client_request.match(args, ... )
	-- body
	local uid = ctx:get_uid()
	skynet.send(".MATCH", "lua", "enter", uid, skynet.self())
	local res = { errorcode=errorcode.SUCCESS}
	return res
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

function client_response.opcode(args, ... )
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

skynet.start(function ( ... )
	-- body
	local host = sprotoloader.load(1):host "package"
	local send_request = host:attach(sprotoloader.load(2))
	ctx = context.new()
	ctx:set_host(host)
	ctx:set_send_request(send_request)
	
	skynet.register_protocol {
		name = "client",
		id = skynet.PTYPE_CLIENT,
		unpack = decode_proto,
	}

	-- todo: dispatch client message
	skynet.dispatch("client", dispatch_client)
	
	skynet.dispatch("lua", function (_, source, command, ...)
		local f = cmd[command]
		local ok, err = pcall(f, ...)
		if ok then
			if err ~= nil then
				skynet.retpack(err)
			end
		else
			log.error(err)
		end
	end)
end)