package.path = "./../../service/host/agent/?.lua;./../../service/host/lualib/?.lua;../../lualib/?.lua;"..package.path
local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local mc = require "multicast"
local dc = require "datacenter"
local util = require "util"
local const = require "const"
local context = require "context"
local log = require "log"

local env       = context.new()
local CMD       = {}
local REQUEST   = {}
local RESPONSE  = {}
local SUBSCRIBE = {}

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

function REQUEST.logout( ... )
	-- body
end

function REQUEST.login(source, uid, sid, secret, g, d)
	-- body
	skynet.error(string.format("%s is login", uid))
	gate = source
	uid = uid
	subid = sid
	game = g
	db = d

	local rnk = skynet.call(lb, "lua", "push", user.csv_id, user.csv_id)
	user.ara_rnk = rnk

	dc.set(user.csv_id, { client_fd=client_fd, addr=skynet.self()})	
	context.user = user

	local onlinetime = os.time()
	user.ifonline = 1
	user.onlinetime = onlinetime
	user:__update_db({"ifonline", "onlinetime"}, const.DB_PRIORITY_2)
	user.friendmgr = friendmgr:loadfriend( user , dc )
	friendrequest.getvalue(user, send_package, send_request)
	--load public email from channel public_emailmgr
	get_public_email()

	subscribe()
	skynet.fork(subscribe)

	local ret = {}
	ret.errorcode = errorcode[1].code
	ret.msg = errorcode[1].msg
	ret.u = {
		uname = user.uname,
		uviplevel = user.uviplevel,
		config_sound = (user.config_sound == 1) and true or false,
		config_music = (user.config_music == 1) and true or false,
		avatar = user.avatar,
		sign = user.sign,
		c_role_id = user.c_role_id,
		level = user.level,
		recharge_rmb = user.recharge_rmb,
		recharge_diamond = user.recharge_diamond,
		uvip_progress = user.uvip_progress,
		cp_hanging_id = user.cp_hanging_id,
		cp_chapter = user.cp_chapter,
		lilian_level = user.lilian_level
	}
	ret.u.uexp = assert(user.u_propmgr:get_by_csv_id(const.EXP)).num
	ret.u.gold = assert(user.u_propmgr:get_by_csv_id(const.GOLD)).num
	ret.u.diamond = assert(user.u_propmgr:get_by_csv_id(const.DIAMOND)).num
	ret.u.love = user.u_propmgr:get_by_csv_id(const.LOVE).num
	ret.u.equipment_list = {}
	for k,v in pairs(user.u_equipmentmgr.__data) do
		table.insert(ret.u.equipment_list, v)
	end
	ret.u.kungfu_list = {}
	for k,v in pairs(user.u_kungfumgr.__data) do
		table.insert(ret.u.kungfu_list, v)
	end
	ret.u.rolelist = {}
	for k,v in pairs(user.u_rolemgr.__data) do
		table.insert(ret.u.rolelist, v)
	end
	
	return true, send_request("login", ret)
end

local function request(name, args, response)
	skynet.error(string.format("line request: %s", name))
    local f = REQUEST[name]
    local ok, result = pcall(f, env, args)
    if ok then
    	return response(result)
    else
    	skynet.error(result)
    	local ret = {}
    	ret.errorcode = errorcode.FAIL
    	return response(ret)
    end
end      

function RESPONSE:finish_achi( ... )
	-- body
	assert(self.errorcode == 1)
	skynet.error(self.msg)
end

local function response(session, args)
	-- body
	skynet.error(string.format("response: %s", name))
    local f = RESPONSE[name]
    local ok, result = pcall(f, env, args)
    if ok then
    else
    	skynet.error(result)
    end
end

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		if sz > 0 then
			return host:dispatch(msg, sz)
		else 
			assert(false)
		end
	end,
	dispatch = function (session, source, type, ...)
		if env.rdtroom then
			skynet.redirect(env.room, skynet.self(), id, session, type, ...)
		else
			if type == "REQUEST" then
				local ok, result  = pcall(request, ...)
				if ok then
					if result then
						send_package(result)
					end
				else
					skynet.error(result)
				end
			elseif type == "RESPONSE" then
				pcall(response, ...)
			else
				assert(false, result)
			end
		end
	end
}	

function CMD:enter_room(source, room)
	-- body
	self.room = room
	self.rdtroom = true
	-- skynet.
	-- for k,v in pairs(t) do
	-- 	assert(room[k] == nil)
	-- 	room[k] = v
	-- 	send_package(send_request(2, { user_id=tonumber(k), name="hello" })) 
	-- end
end

function CMD:newemail(source, subcmd , ... )
	local f = assert( new_emailrequest[ subcmd ] )
	f( new_emailrequest , ... )
end

-- login
function CMD:login(source, uid, subid, secret,... )
	-- body
	self:login(uid, subid, secret)
	return true
end

-- prohibit mult landing
function CMD:logout(source)
	-- body
	skynet.error(string.format("%s is logout", userid))
	logout()
end

-- others serverce disconnect
function CMD:afk(source)
	-- body
	skynet.error(string.format("AFK"))
end

-- begain to wait for client
function CMD.start(conf)
	local fd = conf.client
	local gate = conf.gate
	local version = conf.version
	local index = conf.index
	local last = gate
	
	-- slot 1,2 set at main.lua
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))
	skynet.fork(function()
		while true do
			send_package(send_request "heartbeat")
			skynet.sleep(500)
		end
	end)

	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
end

-- client disconnect, give handshake to gated
function CMD.disconnect()
	-- todo: do something before exit
	skynet.exit()
end

local function update_db()
	-- body
	while true do
		flush_db(const.DB_PRIORITY_3)
		skynet.sleep(100 * 60) -- 1ti == 0.01s
	end
end

skynet.start(function()
	skynet.dispatch("lua", function(_, source, command, ...)
		print("agent is called" , command)
		local f = CMD[command]
		local result = f(env, source, ... )
		if result then
			skynet.ret(skynet.pack(result))
		end
	end)
	-- skynet.fork(update_db)
end)
