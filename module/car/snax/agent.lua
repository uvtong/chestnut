local snax = require "snax"
local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local sproto = require "sproto"
local context = require "agent.acontext"
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
		ctx:set_room(nil)	
		local uid = ctx:get_uid()
		local args = {}
		args.userid = uid
		room.req.leave(args)
	end
	ctx:set_session(nil)
	ctx:logout()
end

function response.afk(fd)
	-- the connection is broken, but the user may back
	snax.printf("AFK")
	local room = ctx:get_room()
	if room then
		ctx:set_room(nil)
		local uid = ctx:get_uid()
		local args = {}
		args.userid = uid
		room.req.leave(args)
	end
	ctx:set_session(nil)
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

function accept.enter_room(roomid, ... )
	-- body
	ctx:send_request("enter_room", {roomid=roomid})
end

function accept.joinroom(args, ... )
	-- body
	log.info("agent joinroom")
	ctx:send_request("joinroom", args)
end

function accept.buffgenerate(args, ... )
	-- body
	ctx:send_request("buffgenerate", args)
end

function accept.deletebuffgenerate(args, ... )
	-- body
	ctx:send_request("deletebuffgenerate", args)
end

function accept.deletebuff(args, ... )
	-- body
	assert(args)
	ctx:send_request("deletebuff", args)
end

function accept.dealbuffvalue(args, ... )
	-- body
	assert(args)
	ctx:send_request("dealbuffvalue", args)
end

function accept.createbuff(args, ... )
	-- body
	assert(args)
	ctx:send_request("createbuff", args)
end

function accept.updateblood(args, ... )
	-- body
	assert(args)
	ctx:send_request("updateblood", args)
end

function accept.exitroom(args, ... )
	-- body
	assert(args)
	ctx:send_request("exitroom", args)
end

function accept.generatebloodentity(args, ... )
	-- body
	assert(args)
	ctx:send_request("generatebloodentity", args)
end

function accept.deletebloodentity(args, ... )
	-- body
	assert(args)
	ctx:send_request("deletebloodentity", args)
end

function accept.die(args, ... )
	-- body
	ctx:send_request("die", args)
	local uid = ctx:get_uid()
	args.userid = uid
	local res = room.req.leave(args)
end

function accept.limit_start(args, ... )
	-- body
	ctx:send_request("limit_start", args)
end

function accept.limit_close(args, ... )
	-- body
	ctx:send_request("limit_close", args)
end

-- client request
local client_request = {}

function client_request.handshake( ... )
	-- body
	ctx:send_request("handshake")
	local res = { errorcode = 1 }
	return res
end

function client_request.enter_room(args, ... )
	-- body
	log.info("enter_room")
	local uid = ctx:get_uid()
	roomkeeper.post.enter(skynet.self(), uid, args.type)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function client_request.joinroom(args)
	local secret = ctx:get_secret()
	local handle, host, port = roomkeeper.req.apply(args.roomid)
	local room = snax.bind(handle , "room")
	ctx:set_room(room)
	local session, ps = room.req.joinroom(skynet.self(), secret, ctx:get_uid())
	ctx:set_session(session)
	return { session = session, host = host, port = port, battleinitdatalst = ps }
end

function client_request.ping( ... )
	-- body
	local res = { errorcode=errorcode.SUCCESS }
	return res
end

function client_request.createbuff(args, ... )
	-- body
	local room = ctx:get_room()
	if room then
		return room.req.createbuff(args)
	else 
		log.error("room no exists")
	end
end

function client_request.updateblood(args, ... )
	-- body
	local room = ctx:get_room()
	if room then
		return room.req.updateblood(args)
	else
		log.error("room no exists")
	end
end

function client_request.exitroom(args, ... )
	-- body
	local room = ctx:get_room()
	if room then
		local res = room.req.leave(args)
		ctx:set_room(nil)
		return res
	else
		local res = {}
		res.errorcode = errorcode.SUCCESS
		return res
	end
end

function client_request.eitbloodentity(args, ... )
	-- body
	local room = ctx:get_room()
	if room then
		local res = room.req.eitbloodentity(args)
		return res
	end
end

function client_request.die(args, ... )
	-- body
	local room = ctx:get_room()
	if room then
		local res = room.req.die(args)
		return res
	end
end

local client_response = {}

function client_response.handshake(args, ... )
	-- body
	if args.errorcode == errorcode.SUCCESS then
		-- log.info("handshake SUCCESS")
	end
end

function client_response.joinroom(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function client_response.buff(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function client_response.buffgenerate(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function client_response.deletebuffgenerate(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function client_response.deletebuff(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function client_response.dealbuffvalue(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function client_response.createbuff(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function client_response.updateblood(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function client_response.exitroom(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function client_response.generatebloodentity(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function client_response.deletebloodentity(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function client_response.die(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function client_response.enter_room(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function client_response.limit_start(args, ... )
	-- body
	assert(args.errorcode == errorcode.SUCCESS)
end

function client_response.limit_close(args, ... )
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
    local f = client_request[name]
    local ok, result = pcall(f, args)
    if ok then
    	local res = response(result)
    	return res
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
	-- log.info("uid %d agent response: %s", ctx:get_uid(), name)
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
