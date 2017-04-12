local dbset = require "dbset"
local assert = assert
local type   = type

local cls = class("s_level_incident_set", dbset)

function cls:ctor(env, dbctx, rdb, wdb, ... )
	-- body
	cls.super.ctor(self, env, dbctx, rdb, wdb)
	self._data        = {}
	self._count       = 0
	self._cap         = 0
	self._tname       = "s_level_incident"
	self._head        = {
		id = {
			pk = true,
			fk = false,
			cn = "id",
			uq = false,
			t = "number",
		},
		time = {
			pk = false,
			fk = false,
			cn = "time",
			uq = false,
			t = "number",
		},
		pos = {
			pk = false,
			fk = false,
			cn = "pos",
			uq = false,
			t = "string",
		},
		buffid = {
			pk = false,
			fk = false,
			cn = "buffid",
			uq = false,
			t = "number",
		},
		radius = {
			pk = false,
			fk = false,
			cn = "radius",
			uq = false,
			t = "number",
		},
		continuedtime = {
			pk = false,
			fk = false,
			cn = "continuedtime",
			uq = false,
			t = "number",
		},
	}

	self._head_ord    = {}
	self._head_ord[1] = self._head['id']
	self._head_ord[2] = self._head['time']
	self._head_ord[3] = self._head['pos']
	self._head_ord[4] = self._head['buffid']
	self._head_ord[5] = self._head['radius']
	self._head_ord[6] = self._head['continuedtime']

	self._pk          = "id"
	self._fk          = ""
	self._stm         = false
	self._entity_cls  = "s_level_incident_entity"
	return self
end

return cls