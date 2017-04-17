local skynet = require "skynet"
require "skynet.manager"
local log = require "log"
local query = require "query"

local tname = "tg_uid"
local server_id = 1
local server_id_shift = 24
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
	if #res > 0 then
		internal_id =  res[1].uid
	else
		internal_id = 10001
		local sql = string.format("insert into %s values (%d, %d)", "tg_count", 1, internal_id)
		query.insert("tg_count", sql)
	end
	-- load userid
	local sql = "select * from tg_uid"
	local res = query.select("uid", sql)
	for i,v in ipairs(res) do
		users[v.uid] = v.suid
	end
	return true
end

function cmd.close( ... )
	-- body
	return true
end

function cmd.kill( ... )
	-- body
	log.info("uid mgr kill")
	skynet.exit()
end

function cmd.login(uid, ... )
	-- body
	assert(uid)
	local id = users[uid]
	if id then
		log.info("old user %d login", id)
		return { new=false, id=id }
	else
		internal_id = (internal_id + 1) & internal_id_mask
		local id = ((server_id << server_id_shift) | internal_id) & id_mask
		log.info("new user %d login", id)

		users[uid] = id
		local sql = string.format("insert into %s values (%s, %d)", tname, uid, id)
		query.insert(tname, sql)

		local sql = string.format("update tg_count set uid=%d where id=1", internal_id)
		query.update("tg_count", sql)
		
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
