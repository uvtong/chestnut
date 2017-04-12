local dbset = require "dbset"
local assert = assert
local type   = type

local cls = class("u_wallet_set", dbset)

function cls:ctor(env, dbctx, rdb, wdb, ... )
	-- body
	cls.super.ctor(self, env, dbctx, rdb, wdb)
	self._data        = {}
	self._count       = 0
	self._cap         = 0
	self._tname       = "u_wallet"
	self._head        = {
		id = {
			pk = true,
			fk = false,
			cn = "id",
			uq = false,
			t = "number",
		},
		uid = {
			pk = false,
			fk = false,
			cn = "uid",
			uq = false,
			t = "number",
		},
		csv_id = {
			pk = false,
			fk = false,
			cn = "csv_id",
			uq = false,
			t = "number",
		},
		num = {
			pk = false,
			fk = false,
			cn = "num",
			uq = false,
			t = "number",
		},
	}

	self._head_ord    = {}
	self._head_ord[1] = self._head['id']
	self._head_ord[2] = self._head['uid']
	self._head_ord[3] = self._head['csv_id']
	self._head_ord[4] = self._head['num']

	self._pk          = "id"
	self._fk          = ""
	self._stm         = false
	self._entity_cls  = "u_wallet_entity"
	return self
end

return cls