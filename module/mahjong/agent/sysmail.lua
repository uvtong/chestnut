local field = require "db.field"
local entity = require "db.entity"
local query = require "query"
local log = require "log"

local cls = class("sysmail", entity)

function cls:ctor(env, dbctx, set, ... )
	-- body
	cls.super.ctor(self, env, dbctx, set)

	self.uid      = field.new(self, "uid", 2, field.data_type.integer)
	self.mailid   = field.new(self, "mailid", 3, field.data_type.integer)
	self.datetime = field.new(self, "datetime", 4, field.data_type.integer)
	self.viewed   = field.new(self, "viewed", 5, field.data_type.integer)
end

function cls:set_uid(value, ... )
	-- body
	self.uid:set_value(value)
end

function cls:set_mailid(value, ... )
	-- body
	self.mailid:set_value(value)
end

function cls:set_datetime(value, ... )
	-- body
	self.datetime:set_value(value)
end

function cls:set_viewed(value, ... )
	-- body
	set.viewed:set_value(value)
end

function cls:update_db( ... )
	-- body
end

function cls:insert_db( ... )
	-- body
	tname = self._set._tname
	local keys = ""
	local values = ""
	for k,v in pairs(self._fields) do
		log.info("test insert_db")
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

	local noexists = ""
	noexists = noexists .. string.format("%s=%d", self.uid.name, self.uid.value)
	noexists = noexists .. " and " .. string.format("%s=%d", self.mailid.name, self.mailid.value)

	local sql = string.format("insert into %s (%s) values (%s) ON DUPLICATE KEY UPDATE %s;", tname, keys, values, noexists)
	query.insert(tname, sql)
end

return cls