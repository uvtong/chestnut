local dbset = require "dbset"
local assert = assert
local type   = type

local cls = class("u_pet_set", dbset)

function cls:ctor(env, dbctx, rdb, wdb, ... )
	-- body
	cls.super.ctor(self, env, dbctx, rdb, wdb)
	self._data        = {}
	self._count       = 0
	self._cap         = 0
	self._tname       = "u_pet"
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
		pet_id = {
			pk = false,
			fk = false,
			cn = "pet_id",
			uq = false,
			t = "number",
		},
		gold = {
			pk = false,
			fk = false,
			cn = "gold",
			uq = false,
			t = "number",
		},
		stage = {
			pk = false,
			fk = false,
			cn = "stage",
			uq = false,
			t = "number",
		},
		level = {
			pk = false,
			fk = false,
			cn = "level",
			uq = false,
			t = "number",
		},
	}

	self._head_ord    = {}
	self.__head_ord[1] = self.__head['id']
	self.__head_ord[2] = self.__head['uid']
	self.__head_ord[3] = self.__head['pet_id']
	self.__head_ord[4] = self.__head['gold']
	self.__head_ord[5] = self.__head['stage']
	self.__head_ord[6] = self.__head['level']

	self._pk          = "id"
	self._fk          = ""
	self._stm         = false
	self._entity_cls  = "u_pet_entity"
	return self
end

return cls