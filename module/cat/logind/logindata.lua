package.path = "./../lualib/?.lua;./../logind/?.lua;"..package.path
package.cpath = "./../lua-cjson/?.so;"..package.cpath
local skynet = require "skynet"
local mc = require "multicast"
local rdb = ".DB"
local wdb = ".DB"

local cls = require("models/areamgr")
local areamgr = cls.new()
local server_id = {
	sample = 1,
	sample2 = 2
}

local function cov(server, uid)
	-- body
	local id = assert(server_id[server])
	id = (uid << 8) | (id & ((1 << 8) - 1))
	return id
end

local CMD = {}

function CMD.get(server, uid)
	-- body
	print(server, uid)
	local id = cov(server, uid)
	print(id)
	local r = areamgr:get(id)
	print("*********88", r)
	if r then
		assert(r.server == server)
		return 1
	else
		return 0
	end
end

function CMD.set(server, uid)
	-- body
	local id = cov(server, uid)
	local tmp = {
		id = id,
		uid = uid,
		server_id = server_id[server],
		server = server
	}
	local r = areamgr:create_entity(tmp)
	areamgr:add(r)
	r:update_wait()
	return 1
end

local START_SUBSCRIBE = {}

function START_SUBSCRIBE.finish(source, ...)
	-- body
	print(string.format("the node logindata %d will be finished. you should clean something.", skynet.self()))
	skynet.send(source, "lua", "exit")
end

local function start_subscribe()
	-- body
	local c = skynet.call(".start_service", "lua", "register")
	local c2 = mc.new {
		channel = c,
		dispatch = function (channel, source, cmd, ...)
			-- body
			local f = START_SUBSCRIBE[cmd]
			if f then
				f(source, ...)
			end
		end
	}
	c2:subscribe()
end

local function update_db()
	-- body
	while true do 
		areamgr:update()
		skynet.sleep(60 * 100)
	end
end

skynet.start(function()
	skynet.dispatch("lua", function(_, source, command, ...)
		print("logindata is called" , command)
		local f = CMD[command]
		local result = f( ... )
		if result then
			skynet.ret(skynet.pack(result))
		end
	end)
	areamgr:load_db_to_data()
	skynet.fork(update_db)
	start_subscribe()
end)