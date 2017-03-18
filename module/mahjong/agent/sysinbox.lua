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
	self._sl = {}
	self._slidx = 0

	self._viewedcnt = 0
	self._noviewedcnt = 0
	self._viewed = {}

	return self
end

function cls:load_db_to_data( ... )
	-- body
	local sql = string.format("select * from %s", set._tname)
	local res = query.select(self._tname, sql)
	if #res > 0 then
		for k,v in pairs(res) do
			local m = sysmail.new(self._env, self._dbctx, self)
			for kk,vv in pairs(v) do
				m[kk].value = vv
				if kk == "viewed" then
					if vv == 1 then
						self._viewed = self._viewed + 1
					else
						self._viewed[v.id] = 0
					end
				end
			end
			self._data[v.mailid] = m 
		end
	end
end

function cls:add(mail, ... )
	-- body
	self._data[mail.mailid.value] = mail
	self._count = self._count + 1
end

function cls:remove(mail, ... )
	-- body
	if self._data[mail.mailid.value] then
		self._data[mail.mailid.value] = nil
		self._count = self._count - 1
	end
end

function cls:insert_sl(mail, ... )
	-- body
	if self._slidx == 0 then
		self._slidx = self._slidx + 1
		self._sl[self._slidx] = mail
	else
		for i=self._slidx,1,-1 do
			local o = self._sl[self._slidx]
			if mail.datetime.value > o.datetime.value then
				self._sl[i + 1] = mail
				self._slidx = self._slidx + 1
				break
			end
		end
	end
end

function cls:poll( ... )
	-- body
	local res = sysmaild.poll(self._viewedcnt, self._viewed)
	log.info("sysinbox poll %d", #res)
	for k,v in pairs(res) do
		local m = sysmail.new(self._env, self._dbctx, self)
		m.uid.value = self._env._suid
		m.mailid.value = v.id
		m.datetime.value = v.datetime
		m.viewed.value = 0
		m:insert_db()
		self:add(m)
		self:insert_sl(m)
	end
end

function cls:fetch(args, ... )
	-- body
	log.info("sysinbox fetch")
	local res = {}
	res.errorcode = errorcode.SUCCESS
	res.noviewed = self._noviewedcnt
	res.inbox = {}
	for k,v in pairs(self._data) do
		log.info("test inbox")
		local mail = {}
		mail.id = v.mailid.value
		mail.datetime = v.datetime.value
		mail.viewed = v.viewed.value
		local x = sysmaild.get(v.mailid.value)
		mail.title = x.title
		mail.content = x.content
		table.insert(res.inbox, mail)
	end
	return res
end

return cls