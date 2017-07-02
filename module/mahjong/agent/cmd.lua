local skynet = require "skynet"
local redis = require "skynet.db.redis"
local log = require "log"
local errorcode = require "errorcode"
local util = require "util"
local const = require "const"

local reload

local conf = {
	host = "127.0.0.1" ,
	port = 6379 ,
	db = 0
}

local CMD = {}

function CMD:start(source, r, ... )
	-- body
	reload = r
	return true
end

function CMD:close(source, ... )
	-- body
	return true
end

function CMD:kill(source, ... )
	-- body
	skynet.exit()
	return noret
end

-- called by gated
function CMD:login(source, gate, uid, subid, secret,... )
	-- body
	local db = redis.connect(conf)
	self:set_db(db)

	if reload then
		local ok, err = xpcall(self.login, debug.msgh, self, gate, uid, subid, secret)
		if not ok then
			skynet.call(".AGENT_MGR", "lua", "exit_at_once", uid)
			return errorcode.LOGIN_AGENT_ERR
		end
	end

	skynet.send(".ONLINE_MGR", "lua", "login", uid)
	
	log.info("login over")
	return errorcode.SUCCESS
end

-- prohibit mult landing
function CMD:logout(source)
	-- body
	local uid = self:get_uid()
	log.info("user %s logout", uid)
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

	local addr = self:get_room()
	if addr then
		skynet.call(addr, "lua", "afk", uid)
	end

	skynet.call(".ONLINE_MGR", "lua", "afk", self._uid)

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
	
	local addr = self:get_room()
	if addr then
		skynet.call(addr, "lua", "authed", self:get_uid())
	end

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


----------------------------called by room------------------
function CMD:deal(source, args, ... )
	-- body
	self:send_request("deal", args)
end

function CMD:ready(source, args, ... )
	-- body
	self:send_request("ready", args)
end

function CMD:take_turn(source, args, ... )
	-- body
	self:send_request("take_turn", args)
end

function CMD:peng(source, args, ... )
	-- body
	self:send_request("peng", args)
end

function CMD:gang(source, args, ... )
	-- body
	self:send_request("gang", args)
end

function CMD:hu(source, args, ... )
	-- body
	self:send_request("hu", args)
end

function CMD:call(source, args, ... )
	-- body
	self:send_request("call", args)
end

function CMD:shuffle(source, args, ... )
	-- body
	self:send_request("shuffle", args)
end

function CMD:dice(source, args, ... )
	-- body
	self:send_request("dice", args)
end

function CMD:lead(source, args, ... )
	-- body
	self:send_request("lead", args)
end

function CMD:over(source, args, ... )
	-- body
	self:send_request("over", args)
end

function CMD:restart(source, args, ... )
	-- body
	self:send_request("restart", args)
end

function CMD:take_restart(source, args, ... )
	-- body
	self:send_request("take_restart", args)
end

function CMD:rchat(source, args, ... )
	-- body
	self:send_request("rchat", args)
end

function CMD:take_xuanpao(source, args, ... )
	-- body
	self:send_request("take_xuanpao", args)
end

function CMD:take_xuanque(source, args, ... )
	-- body
	self:send_request("take_xuanque", args)
end

function CMD:xuanque(source, args, ... )
	-- body
	self:send_request("xuanque", args)
end

function CMD:xuanpao(source, args, ... )
	-- body
	self:send_request("xuanpao", args)
end

function CMD:settle(source, args, ... )
	-- body
	self:send_request("settle", args)
end

function CMD:final_settle(source, args, ... )
	-- body
	self:send_request("final_settle", args)
end

function CMD:roomover(source, args, ... )
	-- body
	self:send_request("roomover", args)
end

return CMD