local s = [[
local entitycpp = require "entitycpp"

local cls = class("%s", entitycpp)

function cls:ctor(mgr, P, ... )
	-- body
	self.__head  = mgr.__head
	self.__head_ord = mgr.__head_ord
	self.__tname = mgr.__tname
	self.__pk    = mgr.__pk
	self.__fk    = mgr.__fk
	self.__rdb   = mgr.__rdb
	self.__wdb   = mgr.__wdb
	self.__stm   = mgr.__stm
	self.__col_updated=0
	self.__fields = %s
	self.__ecol_updated = %s
	for k,v in pairs(self.__head) do
		self.__fields[k] = assert(P[k])
	end
	return self
end

%s
return cls
]]

return s