local skynet = require "skynet"
local errorcode = require "errorcode"

local assert = assert
local pcall = skynet.pcall
local error = skynet.error

local REQUEST = {}

function REQUEST:handshake(args, ... )
	-- body
	self:send_request("handshake")
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function REQUEST:logout( ... )
	-- body
	self:logout()
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

function REQUEST:create(args, ... )
	-- body
	local uid = self:get_uid()
	local res = skynet.call(".ROOM_MGR", "lua", "create", uid, skynet.self(), args)
	return res
end

function REQUEST:join(args, ... )
	-- body
	local res = {}
	local uid = self:get_uid()
	local sid = self:get_subid()
	local agent = skynet.self()
	local name = self._user.nickname.value
	local sex = self._user.sex.value
	local agent = {
		uid = uid,
		sid = sid,
		agent = agent,
		name = name,
		sex = sex
	}
	local addr = skynet.call(".ROOM_MGR", "lua", "apply", args.roomid)
	assert(addr)
	if addr == 0 then
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
	local addr = self:get_room()
	if addr then
		local res = skynet.call(addr, "lua", "on_leave", args)
		self:set_room(nil)
		return res
	else
		local res = {}
		res.errorcode = errorcode.NOEXiST_ROOMID
		return res
	end
end

function REQUEST:first(args, ... )
	-- body
	local entity = self:get_entity()
	local user = entity:get_component("user")
	assert(user)
	return user:first()
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

function REQUEST:toast1(args, msg, sz, ... )
	-- body
	return skynet.call(".ONLINE_MGR", "lua", "toast1", args)
end

function REQUEST:toast2(args, msg, sz, ... )
	-- body
	return skynet.call(".ONLINE_MGR", "lua", "toast2", args)
end

function REQUEST:fetchsysmail(args, ... )
	-- body
	local entity = self:get_entity()
	local sysinbox = entity:get_component("sysinbox")
	return sysinbox:fetch(args)
end

function REQUEST:syncsysmail(args, ... )
	-- body
	return self._sysinbox:sync(args)
end

function REQUEST:viewedsysmail(args, ... )
	-- body
	local entity = self:get_entity()
	local sysinbox = entity:get_component("sysinbox")
	return sysinbox:viewed(args)
end

function REQUEST:records(args, ... )
	-- body
	local entity = self:get_entity()
	local recordmgr = entity:get_component("recordmgr")
	return recordmgr:records(args)
end

function REQUEST:join(args)

	local uid = ctx:get_uid()
	local secret = ctx:get_secret()
	local room = skynet.call(".ROOM_MGR", "lua", "apply", args.roomid)
	ctx:set_room(args.roomid)

	local res = skynet.call(room, "lua", "join", uid, skynet.self(), secret)
	ctx:set_session(res.session)

	return res
end

function REQUEST:born( ... )
	-- body
	local session = ctx:get_session()
	local room = ctx:get_room()
	return room.req.born(session)
end

function REQUEST:opcode(args, ... )
	-- body
	local session = ctx:get_session()
	local room = ctx:get_room()
	return room.req.opcode(session, args)
end

function REQUEST:match(args, ... )
	-- body
	local uid = ctx:get_uid()
	skynet.send(".MATCH", "lua", "enter", uid, skynet.self(), args.mode)
	local res = { errorcode=errorcode.SUCCESS}
	return res
end

----------------------room----------------------------------
local function forward_room(name, ctx, args, msg, sz, ... )
	-- body
	local addr = assert(ctx:get_room())
	local command = "on_"..name
	log.info("route request command %s agent to room", command)
	if addr then
		return skynet.rawcall(addr, "client", msg, sz)
	end
end

function REQUEST:lead(args, ... )
	-- body
	return forward_room("lead", self, args, ...)
end

function REQUEST:call(args, ... )
	-- body
	return forward_room("call", self, args, ...)
end

function REQUEST:shuffle(args, ... )
	-- body
	return forward_room("shuffle", self, args, ...)
end

function REQUEST:dice(args, ... )
	-- body
	return forward_room("dice", self, args, ...)
end

function REQUEST:step(args, ... )
	-- body
	return forward_room("step", self, args, ...)
end

function REQUEST:restart(args, ... )
	-- body
	return forward_room("restart", self, args, ...)
end

function REQUEST:rchat(args, ... )
	-- body
	return forward_room("rchat", self, args, ...)
end

function REQUEST:xuanpao(args, ... )
	-- body
	return forward_room("xuanpao", self, args, ...)
end

function REQUEST:xuanque(args, ... )
	-- body
	return forward_room("xuanque", self, args, ...)
end

return REQUEST