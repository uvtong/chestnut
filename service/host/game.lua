package.path = "../../service/host/lualib/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local const = require "const"

local CMD = {}

local function guid(csv_id)
	-- body
	local r = game.g_uidmgr:get_by_csv_id(csv_id)
	if not r then
		local t = { csv_id=csv_id, entropy=1}
		t = game.g_uidmgr.create(t)
		game.g_uidmgr:add(t)
		t:__insert_db(const.DB_PRIORITY_2)
		return t.entropy
	else
		r.entropy = tonumber(r.entropy) + 1
		return r.entropy
	end
end

local function u_guid(user_id, csv_id)
	-- body
	csv_id = user_id * 10000 + csv_id
	return guid(csv_id)
end

function CMD.u_guid(user_id, csv_id)
	-- body
	assert(type(user_id) == "number" and user_id > 0)
	assert(type(csv_id) == "number" and csv_id > 0)
	return u_guid(user_id, csv_id)
end

function CMD.guid(csv_id)
	-- body
	assert(type(csv_id) == "number" and csv_id > 0)
	return guid(csv_id)
end

local function update_db()
	-- body
	while true do
		if game then
			game.g_uidmgr:update_db(const.DB_PRIORITY_3)
			game.g_randomvalmgr:update_db(const.DB_PRIORITY_3)
		end
		skynet.sleep(100 * 60) -- 1ti == 0.01s
	end
end

skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		print("called", command)
		local f = CMD[command]
		local result = f(...)
		if result then
			skynet.ret(skynet.pack(result))
		end
	end)
	-- skynet.fork(update_db)
	skynet.register ".game"
end)
