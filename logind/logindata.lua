package.path = "./../lualib/?.lua;./../logind/?.lua;"..package.path
package.cpath = "./../lua-cjson/?.so;"..package.cpath
local skynet = require "skynet"
rdb = skynet.localname(".logind_rdb")
wdb = skynet.localname(".logind_wdb")
local areamgr = require "models/areamgr"
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
	local r = areamgr.create(tmp)
	areamgr:add(r)
	r("insert")
	return 1
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
	areamgr("load_db")
end)