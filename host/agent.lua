package.path = "../host/lualib/?.lua;"..package.path
local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local util = require "util"
local dc = require "datacenter"
-- local loader = require "loader"
local errorcode = require "errorcode"

local CMD       = {}
local REQUEST   = {}
local RESPONSE  = {}
local SUBSCRIBE = {}

local env = {}
env.host         = 0
env.send_request = 0
env.gate         = 0
env.uid          = 0
env.subid        = 0
env.secret       = 0
env.user         = 0
env.stm          = require "stm"
env.sharemap     = require "sharemap"
env.sharedata    = require "sharedata"
env.room         = 0
env.rdtroom      = true

local function shuffle( ... )
	-- body
	local cards = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
					17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
					33, 24, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 
					49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61,
					64, 80}
	for i,v in ipairs(cards) do
		local idx = math.random(1, #cards)
		local temp = cards[i]
		cards[i] = cards[idx]
		cards[idx] = t
	end
end 

function REQUEST:enter_room(args)
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode.OFFLINE.errorcode
		ret.msg = errorcode.OFFLINE.msg	
		return ret
	end
	self.user_id = user.csv_id
	self.addr = skynet.self()
	local r = skynet.call(".scene", "lua", "enter_room", self)
	if r.c.name == "left" then
		left = {}
		left.user_id = r.user_id
		left.addr = r.addr
	elseif r.name == "right" then
		right = {}
		right.user_id = r.user_id
		right.addr = r.addr
	end
	ret.errorcode = errorcode.SUCCESS.errorcode
	ret.msg = errorcode.SUCCESS.msg
	return { errorcode=0, msg="ok"}
end

function REQUEST:ready(args)
	-- body
	local ret = {}
	if not user then
		ret.errorcode = errorcode.OFFLINE.errorcode
		ret.msg = errorcode.OFFLINE.msg
		return ret
	end
	assert(user)
	user.ready = self.ready
	self.user_id = user.csv_id
	skynet.send(left.addr, "lua", "ready", self)
	skynet.send(right.addr, "lua", "ready", self)
	ret.errorcode = errorcode.SUCCESS.errorcode
	ret.msg = errorcode.SUCCESS.msg
	return ret
end

function REQUEST:mp(args)
	-- body
end

function REQUEST:am(args)
	-- body
end

function REQUEST:rob(args)
	-- body
	skynet.send(right.addr, "lua", "left.user_id", self.m)
end

function REQUEST:lead(args)
	-- body
end

local function request(name, args, response)
	local f = REQUEST[name]
	if f then
		local ok, result = pcall(f, env, args)
		if ok then
			return response(result)
		else
			local ret = {}
			ret.errorcode = errorcode[29].code
			ret.msg = errorcode[29].msg
			return response(result)
		end
	else
		local ret = {}
		ret.errorcode = errorcode[39].code
		ret.msg = errorcode[39].msg
		return response(result)
	end
end

function RESPONSE:enter_room()
	-- body
	assert(self.errorcode == 0)
end

function RESPONSE:ready()
	-- body
	assert(self.errorcode == 0)
end

function RESPONSE:mp()
	-- body
end

function RESPONSE:deal_cards()
	-- body
end

function RESPONSE:rob()
	-- body
end

function RESPONSE:turn_rob()
	-- body
end

function RESPONSE:mark()
	-- body
end

function RESPONSE:lead()
	-- body
end

function RESPONSE:turn_lead()
	-- body
end

local function response(name, args)
	-- body
	local f = assert(RESPONSE[name])
	f(args)
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = function (msg, sz)
		if env.rdtroom then
			return msg, sz
		else
			if sz == 0 then
				return "HEARTBEAT"
			else	
				return host:dispatch(msg, sz)
			end
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
						skynet.retpack(result)
					end
				else
					skynet.error(result)
				end
			elseif type == "RESPONSE" then
				pcall(response, ...)
			else
				error "other type is not existence."
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

function CMD.ready(t)
	-- body
	room.users[tostring(t.user_id)].ready = t.ready
	send_package(send_request(4, { user_id=user_id, ready=ready}))
end

function CMD.rob(user_id, m)
	-- body
	left.rob = m
	-- turn rob
	send_package(send_request(12, {user_id=user.csv_id, countdown=20}))
end

function CMD.signup(source, uid, sid, sct, g, d)
end

function CMD.login(source, uid, sid, secret, g, d)
	-- body
	skynet.error(string.format("%s is login", uid))
	gate = source
	uid = uid
	subid = sid
	game = g
	db = d

	return true
end

local function logout()
	-- body
	if gate then
		skynet.call(gate, "lua", "logout", userid, subid)
	end
	skynet.exit()
end

function CMD.logout(source)
	-- body
	assert(false)
	skynet.error(string.format("%s is logout", userid))
	logout()
end

function CMD.afk(source)
	-- body
	skynet.error(string.format("AFK"))
end

local function update_db()
	-- body
	while true do
		flush_db(const.DB_PRIORITY_3)
		skynet.sleep(100 * 60) -- 1ti == 0.01s
	end
end

local function start()
	-- body
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		local r = f(...)
		if r then
			skynet.ret(skynet.pack(r))
		end
	end)
	-- skynet.fork(update_db)
	start()	
end)
