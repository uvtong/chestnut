package.path = "./../../module/mahjong/lualib/?.lua;./../../module/mahjong/record/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local const = require "const"
local log = require "log"
local sd = require "sharedata"
local redis = require "redis"
local const = require "const"
local dbmonitor = require "dbmonitor"
local zset = require "zset"

local noret = {}

local conf = {
	host = "127.0.0.1" ,
	port = 6379 ,
	db = 0
}

local CMD = {}

function CMD.start( ... )
	-- body
	db = redis.connect(conf)
	return true
end

function CMD.close( ... )
	-- body
	db:disconnect()
	return true
end

function CMD.kill( ... )
	-- body
	skynet.exit()
end

function CMD.load( ... )
	-- body
	local idx =  db:get(string.format("tb_count:%d:uid", const.RECORD_ID))
	idx = math.tointeger(idx)
	if idx > 1 then
		local keys = db:zrange('tb_record', 0, -1)
		for k,v in pairs(keys) do
			zs:add(k, v)
		end

		for _,id in pairs(keys) do
			local vals = db:hgetall(string.format('tb_record:%s', id))
			local t = {}
			for i=1,#vals,2 do
				local k = vals[i]
				local v = vals[i + 1]
				t[k] = v
			end
			sd.new(string.format('tb_record:%s', id), t)
			-- t = sd.query(string.format('tg_sysmail:%s', id))
		end	
	end
end

function CMD.register(content, ... )
	-- body
	local id =  db:incr(string.format("tb_count:%d:uid", const.RECORD_ID))
	dbmonitor.cache_update(string.format("tb_count:%d:uid", const.RECORD_ID))

	-- sd.new
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