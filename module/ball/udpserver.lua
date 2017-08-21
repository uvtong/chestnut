local skynet = require "skynet"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"
local log = require "skynet.log"
local rudp = require "rudp"


local udphost, udpport
local U
local S = {}
local D = {}
local last = 0
local delta = 25 -- 0.025s

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
	local s = S[session]
	if s and s.u then
		log.info("udp send first handshake")
		local now = skynet.now()
		s.u:send(string.pack("<IIII", now, localtime, 0xffffffff, session))
	end
end

local function send(u, from, data, ... )
	-- body
	if #data > 1 then
		local s = D[from]
		if s and s.address then
			log.info("udp sendto %s, length os data %d", socket.udp_address(s.address), #data)
			socket.sendto(U, s.address, data)
		end
	else
		-- log.info("data length more then 0")
	end
end

local function recv(u, from, data, ... )
	-- body
	log.info(type(from))
	log.info("length of data is %d", #data)
	local localtime, eventtime, session = string.unpack("<III", data, 9)
	skynet.error("localtime:", localtime, "eventtime:", eventtime, "session:", session)
	local s = S[session]
	if s then
		if s.address ~= from then
			skynet.error("udp_servier first time")
			log.info(string.format("secret : %s", string.hex(s.key)))
			
			if crypt.hmac_hash(s.key, data:sub(9)) ~= data:sub(1,8) then
				skynet.error("Invalid signature of session %d from %s", session, socket.udp_address(from))
				return
			end
			skynet.error("test")
			s.address = from
			s.u = u
			D[from] = s
		end
		if eventtime == 0xffffffff then
			log.info("timesync")
			return timesync(session, localtime, from)
		end
		s.time = skynet.now()
		-- NOTICE: after 497 days, the time will rewind
		if s.time > eventtime + timeout then
			skynet.error("The package is delay %f sec", (s.time - eventtime)/100)
			return
		elseif eventtime > s.time then
			-- drop this package, and force time sync
			return timesync(session, localtime, from)
		elseif s.lastevent and eventtime < s.lastevent then
			-- drop older event
			return
		end
		s.lastevent = eventtime
		skynet.send(s.room, "lua", "update", data:sub(9))
	else
		skynet.error("Invalid session %d from %s" , session, socket.udp_address(from))
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

local function update(s, data, ... )
	-- body
	local now = skynet.now()
	local past = now - last
	local tick = 0
	if past >= delta then -- 20 fps
		last = last + delta
		tick = 1
	end
	if s.u then
		if tick > 0 then
			s.u:update(data, tick)
		end
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
	-- log.info("%s, %s", type(str), type(from))
	local s = D[from]
	if s then
		if s.u then
			update(s, str)
		else
			assert(false)
		end
	else
		log.info("dispatch from : %s, str: %s", socket.udp_address(from), str)
		local u = rudp(send, recv)
		u:set_from(from)
		u:update(str, 1)
	end
end

local cmd = {}

function cmd.start(host, port, ... )
	-- body
	udphost = host
	udpport = port
	U = socket.udp(dispatch, host, math.floor(port))
	skynet.fork(keepalive)
	skynet.error("begin to listen udp_servier", host, math.floor(port))
	skynet.fork(tick)
	last = skynet.now()
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
		room = service,
		address = nil,
		time = skynet.now(),
		lastevent = nil,
		u = nil,
	}
	skynet.error("client session", SESSION)
	return { host=udphost, port=udpport, session=SESSION}
end

function cmd.unregister(session)
	S[session] = nil
	return true
end

function cmd.post(session, data)
	local s = S[session]
	if s and s.address and s.u then
		s.u:send(data)
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
