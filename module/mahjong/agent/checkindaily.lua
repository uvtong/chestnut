local field = require "db.field"
local entity = require "db.entity"
local query = require "query"

local cls = class("checkindaily", entity)

function cls:ctor(env, dbctx, set, ... )
	-- body
	cls.super.ctor(self, env, dbctx, set)
	self.uid   = field.new(self, "uid", 2, field.data_type.integer)
	self.month = field.new(self, "month", 3, field.data_type.integer)
	self.count = field.new(self, "count", 4, field.data_type.integer)

	return self
end

function cls:dtor( ... )
	-- body
end

function cls:insert_db(tname, ... )
	-- body
	if tname == nil then
		tname = self._set._tname
	end
	local keys = ""
	local values = ""
	for i,v in ipairs(self._fields) do
		keys = keys .. v.name .. ","
		if v:dt() == field.data_type.integer then
			values = values .. string.format("%d,", v.value)
		elseif v:dt() == field.data_type.biginteger then
			values = values .. string.format("%d,", v.value)
		elseif v:dt() == field.data_type.char then
			values = values .. string.format("'%s',", v.value)
		end
	end
	keys = string.sub(keys, 1, #keys-1)
	values = string.sub(values, 1, #values-1)
	local sql = string.format("insert into %s (%s) values (%s);", tname, keys, values)
	query.insert(tname, sql)
end

function cls:set_uid(value, ... )
	-- body
	self.uid:set_value(value)
end

function cls:set_month(value, ... )
	-- body
	self.month:set_value(value)
end

function cls:set_count(value, ... )
	-- body
	self.count:set_value(value)
end

return cls