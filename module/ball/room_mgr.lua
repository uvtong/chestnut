local skynet = require "skynet"
require "skynet.manager"
local log = require "skynet.log"

local queue = require "queue"


local index = 0
local q
local rooms = {}

local function incre_room( ... )
	-- body
	local size = 10
	for i=1,size do
		local id = index + i
		local addr = skynet.newservice("room/room", id)
		rooms[id] = { addr=addr, id=id}
		q:enqueue(id)
	end
	index = index + size
end

local cmd = {}

function cmd.start( ... )
	-- body
	q = queue()
	incre_room()
	return true
end

function cmd.close( ... )
	-- body
	return true
end

function cmd.kill( ... )
	-- body
end

function cmd.enter( ... )
	-- body
	if #q > 0 then
		return q:dequeue()
	else
		incre_room()
		return q:dequeue()
	end
end

function cmd.exit(id, ... )
	-- body
	q:enqueue(id)
end

function cmd.apply(id, ... )
	-- body
	assert(id)
	local r = rooms[id]
	if r then
		return assert(r.addr)
	else
		log.error("not exist")
		return 0
	end
end

-- todo : close room ?

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function(_,_, command, subcmd, ...)
		local f = cmd[command]
		local r = f(subcmd, ... )
		if r ~= nil then
			skynet.ret(skynet.pack(r))
		end
	end)
	skynet.register ".ROOM_MGR"
end)

