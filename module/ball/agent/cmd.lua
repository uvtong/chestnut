local skynet = require "skynet"
local redis = require "skynet.db.redis"
local log = require "skynet.log"
local errorcode = require "errorcode"
local util = require "util"
local const = require "const"

local assert = assert
local pcall = skynet.pcall
local error = skynet.error

local CMD = {}

function CMD:start(r, ... )
	-- body
	self:set_reload(r)
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
function CMD:login(gate, uid, subid, secret,... )
	-- body
	local ok, err = xpcall(self.login, debug.msgh, self, gate, uid, subid, secret)
	if not ok then
		skynet.call(".AGENT_MGR", "lua", "exit_at_once", uid)
		return errorcode.LOGIN_AGENT_ERR
	end
	return errorcode.SUCCESS
end

-- prohibit mult landing
function CMD:logout()
	-- body
	self:logout()
	
	return true
end

-- begain to wait for client
function CMD:authed(conf)

	log.info("authed")
	local fd      = assert(conf.client)
	local version = assert(conf.version)
	local index   = assert(conf.index)

	self:set_fd(fd)
	self:set_version(version)
	self:set_index(index)

	self:authed()

	return true
end

-- others serverce disconnect
function CMD:afk()
	-- body
	self:afk()

	return true
end



function CMD:info( ... )
	-- body
	return { name="xiaomiao"}
end

function CMD:alter_rcard(num, ... )
	-- body
	local rcard = self._user.rcard.value + num
	self._user:set_rcard(rcard)
end

-- called by room
function CMD:join(args, ... )
	-- body
	self:send_request("join", args)
	return noret
end

function CMD:leave(args, ... )
	-- body
	self:send_request("leave", args)
	return noret
end

function CMD:room_over( ... )
	-- body
	self:set_room(nil)
end

function CMD:record(recordid, names, ... )
	-- body
	local r = self._recordmgr:create(recordid, names)
	self._recordmgr:add(r)
	r:insert_db()
end


----------------------------called by room------------------
function CMD:deal(args, ... )
	-- body
	self:send_request("deal", args)
end

return CMD