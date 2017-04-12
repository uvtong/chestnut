local skynet = require "skynet"
local set = require "db.dbset"
local query = require "query"
local sysmail = require "sysmail"
local sysmaild = require "sysmaild"
local errorcode = require "errorcode"
local log = require "log"

local cls = class("sysinbox", set)

function cls:ctor(env, dbctx, ... )
	-- body
	cls.super.ctor(self, env, dbctx)
	self._tname = "tu_sysmail"
	self._mk = {}
	return self
end

function cls:load_db_to_data( ... )
	-- body
	local sql = string.format("select * from %s where uid=%d and viewed=0", self._tname, self._env._suid)
	local res = query.select(self._tname, sql)
	if #res > 0 then
		for k,v in pairs(res) do
			local m = sysmail.new(self._env, self._dbctx, self)
			for kk,vv in pairs(v) do
				m[kk].value = vv
			end
			self:add(m)
		end
	end
end

function cls:add(mail, ... )
	-- body
	table.insert(self._data, mail)
	self._count = self._count + 1
	self._mk[mail.mailid.value] = mail
end

function cls:poll( ... )
	-- body
	-- local res = sysmaild.poll(self._viewedcnt, self._viewed)
	-- log.info("sysinbox poll %d", #res)
	-- for k,v in pairs(res) do
	-- 	local m = sysmail.new(self._env, self._dbctx, self)
	-- 	m.uid.value = self._env._suid
	-- 	m.mailid.value = v.id
	-- 	m.datetime.value = v.datetime
	-- 	m.viewed.value = 0
	-- 	m:insert_db()
	-- 	self:add(m)
	-- 	self:insert_sl(m)
	-- end
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
			local x = sysmaild.get(v.mailid.value)
			mail.title = x.title
			mail.content = x.content
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
	if #args.all == self._count then
		return res
	else
		for i,v in ipairs(self._data) do
			local mailid = v.mailid.value
			local finded = false
			for ii,vv in ipairs(args.all) do
				if vv == mailid then
					finded = true
				end
			end
			if not finded then
				local mail = {}
				mail.id = v.mailid.value
				mail.datetime = v.datetime.value
				mail.viewed = v.viewed.value
				local x = sysmaild.get(v.mailid.value)
				mail.title = x.title
				mail.content = x.content
				table.insert(res.inbox, mail)
			end
		end
		return res
	end
end

function cls:viewed(args, ... )
	-- body
	local mail = self._mk[args.mailid]
	mail:set_viewed(1)
	mail:update_db(mail.viewed:column())
	local res = {}
	res.errorcode = errorcode.SUCCESS
	return res
end

return cls