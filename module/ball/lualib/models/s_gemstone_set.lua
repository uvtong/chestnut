local dbset = require "dbset"
local assert = assert
local type   = type

local cls = class("s_gemstone_set", dbset)

function cls:ctor(env, dbctx, rdb, wdb, ... )
	-- body
	cls.super.ctor(self, env, dbctx, rdb, wdb)
	self._data        = {}
	self._count       = 0
	self._cap         = 0
	self._tname       = "s_gemstone"
	self._head        = {
		ID = {
			pk = true,
			fk = false,
			cn = "ID",
			uq = false,
			t = "number",
		},
		Blood = {
			pk = false,
			fk = false,
			cn = "Blood",
			uq = false,
			t = "number",
		},
		Fraction = {
			pk = false,
			fk = false,
			cn = "Fraction",
			uq = false,
			t = "number",
		},
	}

	self._head_ord    = {}
	self._head_ord[1] = self._head['ID']
	self._head_ord[2] = self._head['Blood']
	self._head_ord[3] = self._head['Fraction']

	self._pk          = "ID"
	self._fk          = ""
	self._stm         = false
	self._entity_cls  = "s_gemstone_entity"
	return self
end

return cls