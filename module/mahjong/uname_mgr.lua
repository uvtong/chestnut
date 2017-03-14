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

local cmd = {}

function cmd.start( ... )
	-- body
	local sql = "select * from tg_count where id = 2;"
	local res = query.select("tg_count", sql)
	if #res > 0 then
		internal_id = res[1].uid
	else
		internal_id = 10
		local sql = string.format("insert into %s values (%d, %d)", "tg_count", 1, internal_id)
		query.insert("tg_count", sql)
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

function cmd.name( ... )
	-- body
	internal_id = (internal_id + 1) & internal_id_mask
	local id = ((server_id << server_id_shift) | internal_id) & id_mask

	local sql = string.format("update tg_count set uid=%d where id=2", internal_id)
	query.update("tg_count", sql)

	return id
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function (_, source, command, ... )
		-- body
		local f = assert(cmd[command])
		local r = f( ... )
		if r ~= noret then
			skynet.retpack(r)
		end
	end)
	skynet.register ".UNAME_MGR"
end)