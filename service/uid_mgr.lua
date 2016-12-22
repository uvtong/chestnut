local skynet = require "skynet"
require "skynet.manager"
local log = require "log"
local query = require "query"

local server_id = 1
local internal_id = 1
local internal_id_mask = 0xffffff
local id_mask = 0xffffffff
local users = {}

local cmd = {}

function cmd.start( ... )
	-- body
	local sql = "select sid from dizhu.g_count where id = 1;"
	local res = query.select("g_count", sql)
	internal_id =  res[1].uid
	local sql = "select * from uid"
	local res = query.select("uid", sql)
	for i,v in ipairs(res) do
		users[v.uid] = {
			id = v.uid,
			new = false
		}
	end
	return true
end

function cmd.close( ... )
	-- body
	return true
end

function cmd.kill( ... )
	-- body
	skynet.exit()
end

function cmd.login(uid, ... )
	-- body
	local id = users[uid]
	if id then
		return false, id
	else
		internal_id = internal_id + 1 & internal_id_mask
		local id = server_id << 24
		id =  (id | internal_id) & id_mask

		users[uid] = id
		local sql = string.format("insert into uid values (%d, %d)", uid, id)
		query.insert("uid", sql)
		return true, id
	end
end

function cmd.sysemailid( ... )
	-- body
	return 1
end

function cmd.ai( ... )
	-- body
	return 100, 1000
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function (_, source, command, ...)
		local f = cmd[command]
		local ok, err = pcall(f, ...)
		if ok then
			if err ~= nil then
				skynet.retpack(err)
			end
		else
			log.error(err)
		end
	end)
	skynet.register ".UID_MGR"
end)
