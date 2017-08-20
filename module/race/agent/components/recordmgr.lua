local skynet = require "skynet"
local log = require "skynet.log"
local query = require "query"
local errorcode = require "errorcode"
local util = require "util"
local dbmonitor = require "dbmonitor"
local component = require "component"

local CLS_NAME = "recordmgr"

local cls = class(CLS_NAME, component)

function cls:ctor(entity, ... )
	-- body
	cls.super.ctor(self, entity, CLS_NAME)
	self._tname = "tb_user_record"
	self._mk = {}
	return self
end

function cls:load_cache_to_data( ... )
 	-- body
 	local uid = self._entity:get_uid()
 	local keys = self._env._db:zrange(string.format("%s:%d", self._tname, uid), 0, -1)
 	if keys then
 	else
 		dbmonitor.cache_select(string.format("%s:%d", self._tname, uid))
 	end
 	local keys = self._env._db:zrange(string.format("%s:%d", self._tname, uid), 0, -1)
 	if keys then
 		for _,id in pairs(keys) do
 			local key = string.format("%s:%d:%d", self._tname, uid, id)
			local vals = self._env._db:hgetall(key)
			self._mk[math.tointeger(vals.id)] = vals
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
	for i,v in ipairs(self._mk) do
		local record = {}
		record.id       = v.recordid
		record.datetime = v.datetime
		record.player1  = v.player1
		record.player2  = v.player2
		record.player3  = v.player3
		record.player4  = v.player4
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