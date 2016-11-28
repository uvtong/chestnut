local entity = require "entity"

local cls = class("s_gemstone_entity", entity)

function cls:ctor(env, dbctx, set, rdb, wdb, p, ... )
	-- body
	assert(env and dbctx and set and rdb and wdb)
	cls.super.ctor(self, env, dbctx, set, rdb, wdb)
	self._head      = set._head
	self._head_ord  = set._head_ord
	self._tname     = set._tname
	self._pk        = set._pk
	self._fk        = set._fk
	self._stm       = set._stm
	self._col_updated = 0
	self._fields = {
			ID = 0,
			Blood = 0,
			Fraction = 0,
		}

	self._ecol_updated = {
			ID = 0,
			Blood = 0,
			Fraction = 0,
		}

	if p then
		for k,v in pairs(self._head) do
			self._fields[k] = assert(p[k], string.format("no exist %s", k))
		end
	end
	return self
end

return cls