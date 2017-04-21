local skynet = require "skynet"
local set = require "db.dbset"
local query = require "query"
local sysmail = require "sysmail"
local sysmaild = require "sysmaild"
local errorcode = require "errorcode"
local log = require "log"
local sysmail = require "sysmail"
local snowflake = require "snowflake"
local zset = require "zset"
local sd = require "sharedata"

local cls = class("sysinbox", set)

function cls:ctor(env, dbctx, ... )
	-- body
	cls.super.ctor(self, env, dbctx)
	self._tname = "tu_sysmail"
	self._mk = {}
	self._mkzs = zset.new()
	return self
end

function cls:load_cache_to_data( ... )
	local keys = self._env._db:zrange(string.format('tu_sysmail:%d', self._env._suid), 0, -1)
	if keys then
		for _,id in pairs(keys) do
			local i = sysmail.new(self._env, self._dbctx, self)
			i.id.value = math.tointeger(id)
			i.uid.value = self._env._suid
			i:load_cache_to_data()
		end
	end
end

function cls:add(mail, ... )
	-- body
	table.insert(self._data, mail)
	self._count = self._count + 1
	self._mk[mail.mailid.value] = mail
	self._mkzs:add(1, string.format("%d", mail.id.value))
end

function cls:poll( ... )
	-- body
	skynet.fork(function ( ... )
		-- body
		local res
		if self._count > 0 then
			res = sysmaild.poll(self._mkzs:range(self._mkzs:count() - 1, self._mkzs:count())[1])	
		else
			res = sysmaild.poll(0)
		end

		log.info("sysinbox poll %d", #res)
		for _,mailid in pairs(res) do
			local i = sysmail.new(self._env, self._dbctx, self)

			i.id.value = snowflake.next_id()
			i.uid.value = self._env._suid
			i.mailid.value = math.tointeger(mailid)
			i.datetime.value = math.tointeger(sd.query(string.format("tg_sysmail:%s", mailid)).datetime)
			i.viewed.value = 0
			i:insert_cache()

			self:add(i)
		end
	end)
end

function cls:fetch(args, ... )
	-- body
	log.info("sysinbox fetch")
	local res = {}
	res.errorcode = errorcode.SUCCESS
	res.inbox = {}
	for k,v in pairs(self._data) do
		if v.viewed.value == 0 then
			local mail = {}
			mail.id = v.mailid.value
			mail.datetime = v.datetime.value
			mail.viewed = v.viewed.value
			local t = sd.query(string.format("tg_sysmail:%d", v.mailid.value))
			mail.title   = t.title
			mail.content = t.content
			table.insert(res.inbox, mail)
		end
	end
	return res
end

function cls:sync(args, ... )
	-- body
	log.info("sysinbox sync")
	local res = {}
	res.errorcode = errorcode.SUCCESS
	res.inbox = {}
	for k,v in pairs(self._data) do
		if v.viewed.value == 0 then
			local mail = {}
			mail.id = v.mailid.value
			mail.datetime = v.datetime.value
			mail.viewed = v.viewed.value
			local t = sd.query(string.format("tg_sysmail:%d", v.mailid.value))
			mail.title   = t.title
			mail.content = t.content
			table.insert(res.inbox, mail)
		end
	end
	return res
end

function cls:viewed(args, ... )
	-- body
	local mail = self._mk[args.mailid]
	mail:set_viewed(1)
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

return cls