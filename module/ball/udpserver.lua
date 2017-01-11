local skynet = require "skynet"
local socket = require "socket"
local crypt = require "crypt"
local rudp = require "rudp"
local log = require "log"

local udphost, udpport
local U
local S = {}
local D = {}

local SESSION = 0
local timeout = 10 * 60 * 100	-- 10 mins


--[[
	8 bytes hmac   crypt.hmac_hash(key, session .. data)
	4 bytes localtime
	4 bytes eventtime		-- if event time is ff ff ff ff , time sync
	4 bytes session
	padding data
]]

local function timesync(session, localtime, from)
	-- return globaltime .. localtime .. eventtime .. session , eventtime = 0xffffffff
	if rudp_flag then
		local now = skynet.now()
		ru:send(string.pack("<IIII", now, localtime, 0xffffffff, session))
	else
		local now = skynet.now()
		socket.sendto(U, from, string.pack("<IIII", now, localtime, 0xffffffff, session))
	end
end

local function send(s, data, ... )
	-- body
	if #data > 0 then
		socket.sendto(U, s.address, data)
	else
		log.info("data length more then 0")
	end
end

local function update(s, data, ... )
	-- body
	local last = s.last
	local now = skynet.now()
	local past = now - last
	local tick = 0
	if past >= 5 then -- 20 fps
		last = last + 5
		tick = 1
		s.last = last
	end
	s.u:update(s, data, 1)
end

local function recv(s, data, ... )
	-- body
	local localtime, eventtime, session = string.unpack("<III", str, 9)
	-- skynet.error("localtime:", localtime, "eventtime:", eventtime, "session:", session)
	-- local s = S[session]
	if s then
		if s.address ~= from then
			skynet.error("udp_servier first time")
			if crypt.hmac_hash(s.key, str:sub(9)) ~= str:sub(1,8) then
				snax.printf("Invalid signature of session %d from %s", session, socket.udp_address(from))
				return
			end
			s.address = from
			D[from] = s
		end
		if eventtime == 0xffffffff then
			return timesync(session, localtime, from)
		end
		s.time = skynet.now()
		-- NOTICE: after 497 days, the time will rewind
		if s.time > eventtime + timeout then
			snax.printf("The package is delay %f sec", (s.time - eventtime)/100)
			return
		elseif eventtime > s.time then
			-- drop this package, and force time sync
			return timesync(session, localtime, from)
		elseif s.lastevent and eventtime < s.lastevent then
			-- drop older event
			return
		end
		s.lastevent = eventtime
		s.room.post.update(str:sub(9))
	else
		snax.printf("Invalid session %d from %s" , session, socket.udp_address(from))
	end
end

local function keepalive()
	-- trash session after no package last 10 mins (timeout)
	while true do
		local i = 0
		local ti = skynet.now()
		for session, s in pairs(S) do
			i=i+1
			if i > 100 then
				skynet.sleep(3000)	-- 30s
				ti = skynet.now()
				i = 1
			end
			if ti > s.time + timeout then
				S[session] = nil
			end
		end
		skynet.sleep(6000)	-- 1 min
	end
end

local function tick( ... )
	-- body
	while true do
		for session,s in pairs(S) do
			update(s)
		end
		skynet.sleep(10);  -- 0.1s
	end
end

local function dispatch(str, from, ... )
	-- body
	snax.printf(type(from))
	local s = D[from]
	if s then
		if s.u then
			s.u:update(str, tick)
		else
			assert(false)
		end
	else
		snax.printf("dispatch 1 %s", from)
		local u = rudp(send, recv)
		u:set_id(tonumber(from))
		u:update(str, tick)
	end
end

local cmd = {}

function cmd.start(host, port, ... )
	-- body
	udphost = host
	udpport = port
	U = socket.udp(udpdispatch, host, math.floor(port))
	skynet.fork(keepalive)
	skynet.error("begin to do udp_servier", host, math.floor(port))
	skynet.fork(tick)
	return true
end

function cmd.close( ... )
	-- body
	if U then
		socket.close(U)
		U = nil
	end
	return true
end

function cmd.kill( ... )
	-- body
	if U then
		socket.close(U)
		U = nil 
	end
	skynet.exit()
end

function cmd.register(service, key)
	skynet.error("udp_servier response register", udphost, udpport)
	SESSION = (SESSION + 1) & 0xffffffff
	S[SESSION] = {
		session = SESSION,
		key = key,
		room = snax.bind(service, "room"),
		address = nil,
		time = skynet.now(),
		lastevent = nil,
		u = nil,
	}
	skynet.error("client session", SESSION)
	return SESSION
end

function cmd.unregister(session)
	S[session] = nil
end

function cmd.post(session, data)
	local s = S[session]
	if s and s.address then
		if rudp_flag then
			s.u:send(data)
		else
			socket.sendto(U, s.address, data)
		end
	else
		snax.printf("Session is invalid %d", session)
	end
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function(_,_, command, subcmd, ...)
		local f = cmd[command]
		local r = f(subcmd, ... )
		if r ~= nil then
			skynet.ret(skynet.pack(r))
		end
	end)
end)
