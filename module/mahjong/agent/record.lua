local field = require "db.field"
local entity = require "db.entity"
local query = require "query"
local log = require "log"

local cls = class("record", entity)

function cls:ctor(env, dbctx, set, ... )
	-- body
	cls.super.ctor(self, env, dbctx, set)

	self.id       = field.new(self, "id", 1, field.data_type.integer)
	self.uid      = field.new(self, "uid", 2, field.data_type.integer)
	self.recordid = field.new(self, "mailid", 3, field.data_type.integer)
	self.datetime = field.new(self, "datetime", 4, field.data_type.integer)
	self.player1  = field.new(self, "player1", 5, field.data_type.char)
	self.player2  = field.new(self, "player2", 6, field.data_type.char)
	self.player3  = field.new(self, "player3", 7, field.data_type.char)
	self.player4  = field.new(self, "player4", 8, field.data_type.char)
end

function cls:load_cache_to_data( ... )
	local values = self._env._db:hgetall(string.format("tu_record:%d:%d", self.uid.value, self.id.value))
	self.recordid.value = values.recordid
	self.datetime.value = values.datetime
	self.player1.value  = values.player1
	self.player2.value  = values.player2
	self.player3.value  = values.player3
	self.player4.value  = values.player4
end

function cls:insert_db( ... )
	-- body
	tname = self._set._tname
	local keys = ""
	local values = ""
	for k,v in pairs(self._fields) do
		if v.value then
			keys = keys .. v.name .. ","
			if v:dt() == field.data_type.integer then
				values = values .. string.format("%d,", v.value)
			elseif v:dt() == field.data_type.biginteger then
				values = values .. string.format("%d,", v.value)
			elseif v:dt() == field.data_type.char then
				values = values .. string.format("'%s',", v.value)
			end
		end
	end
	keys = string.sub(keys, 1, #keys-1)
	values = string.sub(values, 1, #values-1)

	local noexists = string.format("uid=%d and recordid=%d", self.uid.value, self.recordid.value)
	local sql = string.format("insert into %s (%s) values (%s) ON DUPLICATE KEY UPDATE %s;", tname, keys, values, noexists)
	query.insert(tname, sql)
end

return cls
