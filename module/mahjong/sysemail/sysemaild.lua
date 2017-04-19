package.path = "./../../module/mahjong/sysemail/?.lua;../../module/mahjong/lualib/?.lua;"..package.path
local skynet = require "skynet"
require "skynet.manager"
local query = require "query"
local inbox = require "inbox"
local mail = require "mail"
local util = require "util"
local log = require "log"
local sd = require "sharedata"
local redis = require "redis"
local const = require "const"
local dbmonitor = require "dbmonitor"
local zset = require "zset"

local conf = {
	host = "127.0.0.1" ,
	port = 6379 ,
	db = 0
}

local db
local zs = zset.new()
local res = {}

local function new_mail(title, content, ... )
	-- body
	assert(title and content)
	local idx =  db:incr(string.format("tg_count:%d:uid", const.SYSMAIL_ID))
	idx = math.tointeger(idx)
	db:zadd(string.format("tg_sysmail"), 1, idx)
	zs:add(1, idx)
	dbmonitor.cache_update(string.format("tg_count:%d:uid", const.SYSMAIL_ID))
	sd.new(string.format("tg_sysmail:%s:id", idx), math.tointeger(idx))
	sd.new(string.format("tg_sysmail:%s:datetime", idx), os.time())
	sd.new(string.format("tg_sysmail:%s:title", idx), title)
	sd.new(string.format("tg_sysmail:%s:content", idx), content)
end

local cmd = {}

function cmd.start( ... )
	-- body
	db = redis.connect(conf)
	return true
end

function cmd.close( ... )
	-- body
	db:disconnect()
	return true
end

function cmd.kill( ... )
	-- body
	skynet.exit()
end

function cmd.first( ... )
	-- body
	local idx =  db:get(string.format("tg_count:%d:uid", const.SYSMAIL_ID))
	idx = math.tointeger(idx)
	if idx > 1 then
		local keys = db:zrange('tg_sysmail', 0, -1)
		for k,v in pairs(keys) do
			zs:add(k, v)
		end

		for _,id in pairs(keys) do
			local vals = db:hgetall(string.format('tg_sysmail:%s', id))
			local t = {}
			for i=1,#vals,2 do
				local k = vals[i]
				local v = vals[i + 1]
				t[k] = v
			end
			sd.new(string.format('tg_sysmail:%s', id), t)
			t = sd.query(string.format('tg_sysmail:%s', id))
		end	
		
	else
		new_mail("hello", "welcome mahjong world.")	
	end
end

function cmd.poll(max, ... )
	-- body
	local t = zs:range(1, zs:count())
	if zs:count() > 0 then
		log.info("1")
		if math.tointeger(t[1]) > max then
			log.info("2")
			return t
		elseif t[#t] > max then
			log.info("3")
			local r = {}
			for _,id in ipairs(t) do
				if id > max then
					table.insert(r, id)
				end
			end
			return r
		end
	else
		log.info("4")
		local r = skynet.response()
		table.insert(res, r)
	end
end

skynet.start(function ( ... )
	-- body
	skynet.dispatch("lua", function (_, _, command, subcmd, ... )
		-- body
		log.info("sysemaild command = %s", command)
		local f = cmd[command]
		local r = f(subcmd, ...)
		if r ~= nil then
			skynet.retpack(r)
		end
	end)
	skynet.register ".SYSEMAIL"
end)