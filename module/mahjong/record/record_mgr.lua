package.path = "./../../module/mahjong/lualib/?.lua;./../../module/mahjong/record/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local const = require "const"
local recordmgr = require "recordmgr"
local log = require "log"
local query = require "query"
assert(const)
assert(query)

local noret = {}
local internal_id = 1
local mgr

local function init_internal_id( ... )
	-- body
	local sql = string.format("select * from tg_count where id = %d;", const.COUNT_RECORD_ID)
	local res = query.select("tg_count", sql)
	if #res > 0 then
		internal_id = res[1].uid
	else
		internal_id = 0
		local sql = string.format("insert into tg_count values (%d, %d)", const.COUNT_RECORD_ID, internal_id)
		query.insert("tg_count", sql)
	end
end

local function update_internal_id( ... )
	-- body
	local sql = string.format("update tg_count set uid=%d where id=%d", internal_id, const.COUNT_RECORD_ID)
	log.info(sql)
	query.update("tg_count", sql)
end

local CMD = {}

function CMD.start( ... )
	-- body
	init_internal_id()

	mgr = recordmgr.new()
	mgr:load_db_to_data()

	return true
end

function CMD.close( ... )
	-- body
	return true
end

function CMD.kill( ... )
	-- body
	skynet.exit()
end

function CMD.register(content, ... )
	-- body
	internal_id = internal_id + 1
	update_internal_id()

	local r = mgr:create(internal_id)
	mgr:add(r)
	r:insert_db()
end

skynet.start(function ( ... )
	-- body
	log.info("tst")
	skynet.dispatch("lua", function (_, source, cmd, ... )
		-- body
		local f = assert(CMD[cmd])
		local msgh = function ( ... )
			-- body
			log.info(tostring(...))
			log.info(debug.traceback())
		end
		local ok, err = xpcall(f, msgh, ...)
		if ok then
			if err ~= noret then
				skynet.retpack(err)
			end
		end
	end)
	skynet.register ".RECORD_MGR"
end)