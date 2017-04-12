local dbset = require "dbset"
local assert = assert
local type   = type

local cls = class("s_buff_set", dbset)

function cls:ctor(env, dbctx, rdb, wdb, ... )
	-- body
	cls.super.ctor(self, env, dbctx, rdb, wdb)
	self._data        = {}
	self._count       = 0
	self._cap         = 0
	self._tname       = "s_buff"
	self._head        = {
		id = {
			pk = true,
			fk = false,
			cn = "id",
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
		accelerateadd = {
			pk = false,
			fk = false,
			cn = "accelerateadd",
			uq = false,
			t = "number",
		},
		hpadd = {
			pk = false,
			fk = false,
			cn = "hpadd",
			uq = false,
			t = "number",
		},
		damageadd = {
			pk = false,
			fk = false,
			cn = "damageadd",
			uq = false,
			t = "number",
		},
		invinciblecount = {
			pk = false,
			fk = false,
			cn = "invinciblecount",
			uq = false,
			t = "number",
		},
		accelerateminus = {
			pk = false,
			fk = false,
			cn = "accelerateminus",
			uq = false,
			t = "number",
		},
		hpminus = {
			pk = false,
			fk = false,
			cn = "hpminus",
			uq = false,
			t = "number",
		},
		damageminus = {
			pk = false,
			fk = false,
			cn = "damageminus",
			uq = false,
			t = "number",
		},
	}

	self._head_ord    = {}
	self._head_ord[1] = self._head['id']
	self._head_ord[2] = self._head['continuedtime']
	self._head_ord[3] = self._head['accelerateadd']
	self._head_ord[4] = self._head['hpadd']
	self._head_ord[5] = self._head['damageadd']
	self._head_ord[6] = self._head['invinciblecount']
	self._head_ord[7] = self._head['accelerateminus']
	self._head_ord[8] = self._head['hpminus']
	self._head_ord[9] = self._head['damageminus']

	self._pk          = "id"
	self._fk          = ""
	self._stm         = false
	self._entity_cls  = "s_buff_entity"
	return self
end

return cls