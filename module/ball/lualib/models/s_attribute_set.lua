local dbset = require "dbset"
local assert = assert
local type   = type

local cls = class("s_attribute_set", dbset)

function cls:ctor(env, dbctx, rdb, wdb, ... )
	-- body
	cls.super.ctor(self, env, dbctx, rdb, wdb)
	self._data        = {}
	self._count       = 0
	self._cap         = 0
	self._tname       = "s_attribute"
	self._head        = {
		ID = {
			pk = true,
			fk = false,
			cn = "ID",
			uq = false,
			t = "number",
		},
		baseHP = {
			pk = false,
			fk = false,
			cn = "baseHP",
			uq = false,
			t = "number",
		},
		playerbaseHurt = {
			pk = false,
			fk = false,
			cn = "playerbaseHurt",
			uq = false,
			t = "number",
		},
		baseVel = {
			pk = false,
			fk = false,
			cn = "baseVel",
			uq = false,
			t = "number",
		},
		baseMass = {
			pk = false,
			fk = false,
			cn = "baseMass",
			uq = false,
			t = "number",
		},
		thrust = {
			pk = false,
			fk = false,
			cn = "thrust",
			uq = false,
			t = "number",
		},
		resistance = {
			pk = false,
			fk = false,
			cn = "resistance",
			uq = false,
			t = "number",
		},
	}

	self._head_ord    = {}
	self._head_ord[1] = self._head['ID']
	self._head_ord[2] = self._head['baseHP']
	self._head_ord[3] = self._head['playerbaseHurt']
	self._head_ord[4] = self._head['baseVel']
	self._head_ord[5] = self._head['baseMass']
	self._head_ord[6] = self._head['thrust']
	self._head_ord[7] = self._head['resistance']

	self._pk          = "ID"
	self._fk          = ""
	self._stm         = false
	self._entity_cls  = "s_attribute_entity"
	return self
end

return cls