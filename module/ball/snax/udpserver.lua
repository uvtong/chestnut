local skynet = require "skynet"
local socket = require "socket"
local crypt = require "crypt"
local snax = require "snax"
local rudp = require "rudp"

local tick = 1
local udphost, udpport
local U
local S = {}
local SESSION = 0
local timeout = 10 * 60 * 100	-- 10 mins
local D = {}

--[[
	8 bytes hmac   crypt.hmac_hash(key, session .. data)
	4 bytes localtime
	4 bytes eventtime		-- if event time is ff ff ff ff , time sync
	4 bytes session
	padding data
]]

local function udpdispatch(str, from)
	local localtime, eventtime, session = string.unpack("<III", str, 9)
	-- skynet.error("localtime:", localtime, "eventtime:", eventtime, "session:", session)
	local s = S[session]
	if s then
		if s.address ~= from then
			skynet.error("udp_servier first time")
			if crypt.hmac_hash(s.key, str:sub(9)) ~= str:sub(1,8) then
				snax.printf("Invalid signature of session %d from %s", session, socket.udp_address(from))
				return
			end
			s.address = from
			s.u
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

local function send(u, session, data, ... )
	-- body
	local s = S[session]
	if s and s.address then
		socket.sendto(U, s.address, data)
	else
		snax.printf("Session is invalid %d", session)
	end
end

local function recv(u, session, data, ... )
	-- body
	udpdispatch(data, session)
end

function response.register(service, key)
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

function response.unregister(session)
	S[session] = nil
end

function accept.post(session, data)
	local s = S[session]
	if s and s.address then
		-- socket.sendto(U, s.address, data)
		s.u:send(data)
	else
		snax.printf("Session is invalid %d", session)
	end
end

local function timesync(session, localtime, from)
	-- return globaltime .. localtime .. eventtime .. session , eventtime = 0xffffffff
	-- local now = skynet.now()
	-- socket.sendto(U, from, string.pack("<IIII", now, localtime, 0xffffffff, session))
	local now = skynet.now()
	ru:send(string.pack("<IIII", now, localtime, 0xffffffff, session))
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

local function update( ... )
	-- body
	while true do
		tick = tick + 1
		for session,s in pairs(S) do
			s.u:update("", tick)
		end
		skynet.sleep(10);  -- 0.1s
	end
end

local function dispatch(str, from, ... )
	-- body
	local s = D[from]
	if s then
		if s.u then
			s.u:update(str, tick)
		else	
			s.u = rudp(send, recv)
			s.u:set_session(s.session)
		end
	else
		local u = rudp(send, recv)
		u:update(str, tick)
	end
end

local function function_name( ... )
	-- body
end

function init(host, port, address)
	U = socket.udp(dispatch, host, math.floor(port))
	skynet.fork(keepalive)
	skynet.error("begin to do udp_servier", host, math.floor(port))
	udphost = host
	udpport = port
	skynet.fork(update)
end

function exit()
	if U then
		socket.close(U)
		U = nil
	end
end


