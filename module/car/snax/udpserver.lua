local skynet = require "skynet"
local socket = require "socket"
local crypt = require "crypt"
local snax = require "snax"
local rudp = require "rudp"
local log = require "log"

local tick = 1
local udphost, udpport
local U
local S = {}
local SESSION = 0
local timeout = 10 * 60 * 100	-- 10 mins
local D = {}
local rudp_flag = false

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

local function send(u, id, data, ... )
	-- body
	local s = D[id]
	if s and (s.address == id) then
		socket.sendto(U, s.address, data)
	else
		snax.printf("Session is invalid %d", session)
	end
end

local function recv(u, from, data, ... )
	-- body
	snax.printf("1.recv %d, %s", from, data)
	udpdispatch(data, from)
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
		if rudp_flag then
			s.u:send(data)
		else
			socket.sendto(U, s.address, data)
		end
	else
		-- snax.printf("Session is invalid %d", session)
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

local function update( ... )
	-- body
	while true do
		tick = tick + 1
		for session,s in pairs(S) do
			if s.u then
				s.u:update("", tick)
			end
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

function init(host, port, address)
	U = socket.udp(udpdispatch, host, math.floor(port))
	skynet.fork(keepalive)
	skynet.error("begin to do udp_servier", host, math.floor(port))
	udphost = host
	udpport = port
	-- skynet.fork(update)
end

function exit()
	if U then
		socket.close(U)
		U = nil
	end
end


