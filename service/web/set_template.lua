local s = [[
local dbset = require "dbset"
local assert = assert
local type   = type

local cls = class("%s", dbset)

function cls:ctor(env, dbctx, rdb, wdb, ... )
	-- body
	cls.super.ctor(self, env, dbctx, rdb, wdb)
	self.__data    = {}
	self.__count   = 0
	self.__cap     = 0
	self.__tname   = "%s"
	self.__head    = %s
	self.__head_ord = {}
	%s
	self.__pk      = "%s"
	self.__fk      = "%s"
	self.__stm     = false
	self.__entity  = "%s"
	return self
end

return cls]]

return s