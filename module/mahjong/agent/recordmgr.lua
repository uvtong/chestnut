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
	self._tname = "tu_record"
	self._mk = {}
	return self
end

function cls:load_db_to_data( ... )
	-- body
	local sql = string.format("select * from %s where uid=%d", self._tname, self._env._suid)
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

function cls:records(args, ... )
	-- body
	local res = {}
	res.errorcode = errorcode.SUCCESS
	res.records = {}
	for i,v in ipairs(self._data) do
		local record = {}
		record.id = v.recordid.value
		record.datetime = v.datetime.value
		record.player1 = v.player1.value
		record.player2 = v.player2.value
		record.player3 = v.player3.value
		record.player4 = v.player4.value
		table.insert(res.records, record)
	end
	return res
end

return cls