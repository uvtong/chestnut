local entitycpp = require "entitycpp"

local cls = class("logintimesentity", entitycpp)

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
	self.__fields = {
			uid = 0,
			times = 0,
		}

	self.__ecol_updated = {
			uid = 0,
			times = 0,
		}

	for k,v in pairs(self.__head) do
		self.__fields[k] = assert(P[k])
	end
	return self
end

function cls:set_uid(v, ... )
	-- body
	assert(v)
	self.__fields.uid = v
end

function cls:get_uid( ... )
	-- body
	return self.__fields.uid
end

function cls:set_times(v, ... )
	-- body
	assert(v)
	self.__fields.times = v
end

function cls:get_times( ... )
	-- body
	return self.__fields.times
end


return cls
