local dbset = require "dbset"
local assert = assert
local type   = type

local cls = class("account_set", dbset)

function cls:ctor(env, dbctx, rdb, wdb, ... )
	-- body
	cls.super.ctor(self, env, dbctx, rdb, wdb)
	self._data        = {}
	self._count       = 0
	self._cap         = 0
	self._tname       = "account"
	self._head        = {
		id = {
			pk = true,
			fk = false,
			cn = "id",
			uq = false,
			t = "number",
		},
		username = {
			pk = false,
			fk = false,
			cn = "username",
			uq = false,
			t = "string",
		},
		password = {
			pk = false,
			fk = false,
			cn = "password",
			uq = false,
			t = "string",
		},
	}

	self._head_ord    = {}
	self._head_ord[1] = self._head['id']
	self._head_ord[2] = self._head['username']
	self._head_ord[3] = self._head['password']

	self._pk          = "id"
	self._fk          = ""
	self._stm         = false
	self._entity_cls  = "account_entity"
	return self
end

return cls