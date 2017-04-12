local dbset = require "dbset"
local assert = assert
local type   = type

local cls = class("s_leveldistrictinfo_set", dbset)

function cls:ctor(env, dbctx, rdb, wdb, ... )
	-- body
	cls.super.ctor(self, env, dbctx, rdb, wdb)
	self._data        = {}
	self._count       = 0
	self._cap         = 0
	self._tname       = "s_leveldistrictinfo"
	self._head        = {
		ID = {
			pk = true,
			fk = false,
			cn = "ID",
			uq = false,
			t = "number",
		},
		ResourceName = {
			pk = false,
			fk = false,
			cn = "ResourceName",
			uq = false,
			t = "string",
		},
		roadSize = {
			pk = false,
			fk = false,
			cn = "roadSize",
			uq = false,
			t = "string",
		},
		playerInitialPosition = {
			pk = false,
			fk = false,
			cn = "playerInitialPosition",
			uq = false,
			t = "string",
		},
		IncidentID = {
			pk = false,
			fk = false,
			cn = "IncidentID",
			uq = false,
			t = "string",
		},
		cycle = {
			pk = false,
			fk = false,
			cn = "cycle",
			uq = false,
			t = "number",
		},
		Gametime = {
			pk = false,
			fk = false,
			cn = "Gametime",
			uq = false,
			t = "number",
		},
		gemstones = {
			pk = false,
			fk = false,
			cn = "gemstones",
			uq = false,
			t = "string",
		},
		Refresh = {
			pk = false,
			fk = false,
			cn = "Refresh",
			uq = false,
			t = "number",
		},
	}

	self._head_ord    = {}
	self._head_ord[1] = self._head['ID']
	self._head_ord[2] = self._head['ResourceName']
	self._head_ord[3] = self._head['roadSize']
	self._head_ord[4] = self._head['playerInitialPosition']
	self._head_ord[5] = self._head['IncidentID']
	self._head_ord[6] = self._head['cycle']
	self._head_ord[7] = self._head['Gametime']
	self._head_ord[8] = self._head['gemstones']
	self._head_ord[9] = self._head['Refresh']

	self._pk          = "ID"
	self._fk          = ""
	self._stm         = false
	self._entity_cls  = "s_leveldistrictinfo_entity"
	return self
end

return cls