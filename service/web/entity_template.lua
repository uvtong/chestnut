local s = [[
local entity = require "entity"

local cls = class("%s", entity)

function cls:ctor(env, dbctx, set, p, ... )
	-- body
	cls.super.ctor(self, env, dbctx, set, p, ...)
	self.__head  = set.__head
	self.__head_ord = set.__head_ord
	self.__tname = set.__tname
	self.__pk    = set.__pk
	self.__fk    = set.__fk
	self.__rdb   = set.__rdb
	self.__wdb   = set.__wdb
	self.__stm   = set.__stm
	self.__col_updated=0
	self.__fields = %s
	self.__ecol_updated = %s
	for k,v in pairs(self.__head) do
		self.__fields[k] = assert(p[k], %s)
	end
	return self
end

return cls
]]

return s