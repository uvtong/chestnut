local skynet = require "skynet"
local set = require "db.dbset"
local query = require "query"
local record = require "record"
local errorcode = require "errorcode"

local cls = class("record", set)

function cls:ctor(env, dbctx, ... )
	-- body
	cls.super.ctor(self, env, dbctx)

	self._tname = "tg_record"
	self._mk = {}
	return self
end

function cls:load_db_to_data( ... )
	-- body
	local sql = string.format("select * from %s", self._tname)
	local res = query.select(self._tname, sql)
	if #res > 0 then
		for k,v in pairs(res) do
			local m = record.new(self._env, self._dbctx, self)
			for kk,vv in pairs(v) do
				m[kk].value = vv
			end
			self:add(m)
		end
	end
end

function cls:add(r, ... )
	-- body
	table.insert(self._data, r)
	self._count = self._count + 1
	self._mk[r.id.value] = r
end


return cls