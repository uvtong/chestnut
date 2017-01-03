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
	-- load internal_id
	local sql = "select * from tg_count where id = 1;"
	local res = query.select("tg_count", sql)
	internal_id =  res[1].uid
	-- load userid
	local sql = "select * from tg_uid"
	local res = query.select("uid", sql)
	for i,v in ipairs(res) do
		users[v.userid] = v.uid
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

function cmd.login(userid, ... )
	-- body
	assert(userid)
	log.info("userid %d from boss", userid)
	local id = users[userid]
	if id then
		log.info("old user %d login", id)
		return { new=false, id=id }
	else
		internal_id = internal_id + 1 & internal_id_mask
		local id = server_id << 24
		id =  (id | internal_id) & id_mask
		log.info("new user %d login", id)

		users[userid] = id
		local sql = string.format("insert into tg_uid values (%d, %d)", userid, id)
		query.insert("uid", sql)

		local sql = string.format("update tg_count set uid=%d where id=1", internal_id)
		query.update("g_count", sql)
		
		return { new=true, id=id}
	end
end

function cmd.query(uid, ... )
	-- body
	return users[uid]
end

function cmd.sysemaild( ... )
	-- body
	return 1
end

function cmd.ai( ... )
	-- body
	return { min=100, max=1000}
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function (_, source, command, ...)
		local f = cmd[command]
		local ok, err = pcall(f, ...)
		if ok then
			if err ~= nil then
				log.info("UID_MGR command: %s", command)
				skynet.retpack(err)
			end
		else
			log.error(err)
		end
	end)
	skynet.register ".UID_MGR"
end)
