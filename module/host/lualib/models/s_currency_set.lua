local dbset = require "dbset"
local assert = assert
local type   = type

local cls = class("s_currency_set", dbset)

function cls:ctor(env, dbctx, rdb, wdb, ... )
	-- body
	cls.super.ctor(self, env, dbctx, rdb, wdb)
	self._data        = {}
	self._count       = 0
	self._cap         = 0
	self._tname       = "s_currency"
	self._head        = {
		csv_id = {
			pk = true,
			fk = false,
			cn = "csv_id",
			uq = false,
			t = "number",
		},
		name = {
			pk = false,
			fk = false,
			cn = "name",
			uq = false,
			t = "string",
		},
	}

	self._head_ord    = {}
	self._head_ord[1] = self._head['csv_id']
	self._head_ord[2] = self._head['name']

	self._pk          = "csv_id"
	self._fk          = ""
	self._stm         = false
	self._entity_cls  = "s_currency_entity"
	return self
end

return cls