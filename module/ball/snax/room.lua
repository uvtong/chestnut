local skynet = require "skynet"
local snax = require "snax"
local errorcode = require "errorcode"
local math3d = require "math3d"
local float = require "float"
local crypt = require "crypt"
local room_scene = require "room.scene"
local log = require "log"
local list = require "list"

-- context variable
local max_number = 4
local roomid
local gate
local users = {}
local aoi
local scene
local map

--[[
	4 bytes localtime
	4 bytes eventtime		-- if event time is ff ff ff ff , time sync
	4 bytes session
	padding data
]]

function accept.update(data)
	skynet.error(#data)
	local session, protocol = string.unpack("<II", data, 9)
	if protocol == 1 then
		local px, py, pz, dx, dy, dz = string.unpack("<ffffff", data, 17)
		log.info("px:%f, py:%f, pz:%f, dx:%f, dy:%f, dz:%f", px, py, pz, dx, dy, dz)
		local position = math3d.vector3(px, py, pz)
		local direction = math3d.vector3(dx, dy, dz)
		scene:update(session, position, direction)
		local time = skynet.now()
		snax.printf("globletime: %d", time)
		local padding = string.pack("<I", 1)
		data = string.pack("<I", time) .. data .. padding
		snax.printf("length of data: %d", #data)
		for s,v in pairs(users) do
			gate.post.post(s, data)
		end
	end
end

function accept.message( ... )
	-- body
	local ba = 1
end

function response.join(agent, secret)
	local n = 0
	for _ in pairs(users) do
		n = n + 1
	end
	if n >= max_number then
		return false	-- max number of room
	end
	agent = snax.bind(agent, "agent")
	local user = {
		agent = agent,
		key = secret,
		session = gate.req.register(skynet.self(), secret),
	}
	users[user.session] = user

	-- return all balls
	local head = scene._list
	local all = {}
	local li = head.next
	while li do
		snax.printf("circle.")
		local ball = li.data
		assert(ball)
		local radis = ball:get_radis()
		local length = ball:get_length()
		local width = ball:get_width()
		local height = ball:get_height()
		local res = {}
		res.errorcode = errorcode.SUCCESS
		res.uid = ball:get_uid()
		res.session = ball:get_session()
		res.radis = radis
		res.length = length
		res.width = width
		res.height = height
		res.px = ball:pack_sproto_px()
		res.py = ball:pack_sproto_py()
		res.pz = ball:pack_sproto_pz()
		res.dx = ball:pack_sproto_dx()
		res.dy = ball:pack_sproto_dy()
		res.dz = ball:pack_sproto_dz()
		res.vel = ball:pack_sproto_vel()
		table.insert(all, res)
		li = li.next
	end
	return user.session, all
end

function response.leave(session)
	for k,v in pairs(users) do
		if k ~= session then
			local agent = v.agent
			agent.post.leave({ session = session })
		end
	end
	scene:leave(session)
	gate.req.unregister(session)
	users[session] = nil
end

function response.query(session)
	local user = users[session]
	-- todo: we can do more
	if user then
		return user.agent.handle
	end
end

function response.born(session, source, uid, ... )
	-- body
	local b = scene:born(source, session)
	b:set_uid(uid)
	local ball = b
	assert(ball)
	local radis = ball:get_radis()
	local length = ball:get_length()
	local width = ball:get_width()
	local height = ball:get_height()
	local res = {}
	res.errorcode = errorcode.SUCCESS
	res.uid = uid
	res.session = session
	res.radis = radis
	res.length = length
	res.width = width
	res.height = height
	res.px = ball:pack_sproto_px()
	res.py = ball:pack_sproto_py()
	res.pz = ball:pack_sproto_pz()
	res.dx = ball:pack_sproto_dx()
	res.dy = ball:pack_sproto_dy()
	res.dz = ball:pack_sproto_dz()
	res.vel = ball:pack_sproto_vel()

	for k,v in pairs(users) do
		if k ~= session then
			snax.printf("test this is passed.")
			local agent = v.agent
			agent.post.born({ b = res })
		end
	end

	return { errorcode = errorcode.SUCCESS, b = res }
end

function init(id, udpserver)
	roomid = id
	gate = snax.bind(udpserver, "udpserver")
	aoi = skynet.newservice("aoi")
	scene = room_scene.new()
	map = scene:create_map()
end

function exit()
	for _,user in pairs(users) do
		gate.req.unregister(user.session)
	end
end

