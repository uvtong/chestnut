local skynet = require "skynet"
local set = require "db.dbset"
local query = require "query"
local record = require "record"
local errorcode = require "errorcode"
local log = require "log"
local util = require "util"
local dbmonitor = require "dbmonitor"

local cls = class("sysinbox", set)

function cls:ctor(env, dbctx, ... )
	-- body
	cls.super.ctor(self, env, dbctx)
	self._tname = "tu_record"
	self._mk = {}
	return self
end

function cls:load_cache_to_data( ... )
 	-- body
 	local keys = self._env._db:zrange(string.format("tu_record:%d", self._env._suid), 0, -1, 'withscores')
 	if keys then
 	else
 		dbmonitor.cache_select(string.format("tu_record:%d", self._env._suid))
 	end
 	local keys = self._env._db:zrange(string.format("tu_record:%d", self._env._suid), 0, -1, 'withscores')
 	if keys then
 		for k,v in pairs(keys) do
 			local m = record.new(self._env, self._dbctx, self)
 			m.id.value = v
 			m.uid.value = self._suid
 			m:load_cache_to_data()
 			self:add(m)
 		end
 	end
end

function cls:add(item, ... )
	-- body
	table.insert(self._data, mail)
	self._count = self._count + 1
	self._mk[item.id.value] = item
end

function cls:load_db_to_data( ... )
	-- body

	local sql = string.format("select * from %s where uid=%d", self._tname, self._env._suid)
	local res = query.select(self._tname, sql)
	if #res > 0 then
		for k,v in pairs(res) do
			
			for kk,vv in pairs(v) do
				m[kk].value = vv
			end
			self:add(m)
		end
	end
end

function cls:create(recordid, names, ... )
	-- body
	local r = record.new(self._env, self._dbctx, self)
	r.id.value = recordid
	r.uid = self._env._suid
	r.datetime = os.time()
	r.player1 = names[1]
	r.player2 = names[2]
	r.player3 = names[3]
	r.player4 = names[4]
	return r
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

function cls:record(recordid, names, ... )
	-- body
	local i = record.new(self._env, self._dbctx, self)
	i.uid.value = self._env._suid
	i.recordid = recordid
	i.datetime = os.time()
	i.player1 = names[1]
	i.player2 = names[2]
	i.player3 = names[3]
	i.player4 = names[4]
	i:insert_db()
end

return cls