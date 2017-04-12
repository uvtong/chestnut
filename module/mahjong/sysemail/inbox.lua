local set = require "db.dbset"
local query = require "query"
local mail = require "mail"
local log = require "log"

local cls = class("inbox", set)

function cls:ctor(env, dbctx, ... )
	-- body
	cls.super.ctor(self, env, dbctx)
	self._tname = "tg_sysmail"
	return self
end

function cls:load_db_to_data( ... )
	-- body
	log.info("my load_db_to_data")
	local sql = string.format("select * from %s", self._tname)
	local res = query.select(self._tname, sql)
	if #res > 0 then
		for k,v in pairs(res) do
			local m = mail.new(self._env, self._dbctx, self)
			for kk,vv in pairs(v) do
				m[kk].value = vv
			end
			self:add(m)
		end
	end
end

function cls:add(mail, ... )
	-- body
	assert(mail)
	self._data[mail.id.value] = mail
	self._count = self._count + 1
end

function cls:remove(mail, ... )
	-- body
	if self._data[mail.id.value] then
		set._data[mail.id.value] = nil
		self._count = self._count - 1
	end
end

function cls:poll(cnt, viewed, ... )
	-- body
	local res = {}
	if cnt == 0 then
		for k,v in pairs(self._data) do
			local mail = {}
			mail.id = v.id.value
			mail.datetime = v.datetime.value
			table.insert(res, mail)
		end
		return res
	elseif cnt >= myin._count then
		return res
	else

	end
end

return cls