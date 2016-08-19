local dbset = require "dbset"
local assert = assert
local type   = type

local cls = class("user_set", dbset)

function cls:ctor(env, dbctx, rdb, wdb, ... )
	-- body
	cls.super.ctor(self, env, dbctx, rdb, wdb)
	self._data        = {}
	self._count       = 0
	self._cap         = 0
	self._tname       = "user"
	self._head        = {
		id = {
			pk = true,
			fk = false,
			cn = "id",
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
	}

	self._head_ord    = {}
	self.__head_ord[1] = self.__head['id']
	self.__head_ord[2] = self.__head['pet_id']

	self._pk          = "id"
	self._fk          = ""
	self._stm         = false
	self._entity_cls  = "user_entity"
	return self
end

return cls