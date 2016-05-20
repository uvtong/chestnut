local entitycpp = require "entitycpp"

local cls = class("g_lilian_phy_powerentity", entitycpp)

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
			id = 0,
			csv_id = 0,
			dioment = 0,
			reset_quanguan_dioment = 0,
		}

	self.__ecol_updated = {
			id = 0,
			csv_id = 0,
			dioment = 0,
			reset_quanguan_dioment = 0,
		}

	for k,v in pairs(self.__head) do
		self.__fields[k] = assert(P[k])
	end
	return self
end

function cls:set_id(v, ... )
	-- body
	assert(v)
	self.__fields.id = v
end

function cls:get_id( ... )
	-- body
	return self.__fields.id
end

function cls:set_csv_id(v, ... )
	-- body
	assert(v)
	self.__fields.csv_id = v
end

function cls:get_csv_id( ... )
	-- body
	return self.__fields.csv_id
end

function cls:set_dioment(v, ... )
	-- body
	assert(v)
	self.__fields.dioment = v
end

function cls:get_dioment( ... )
	-- body
	return self.__fields.dioment
end

function cls:set_reset_quanguan_dioment(v, ... )
	-- body
	assert(v)
	self.__fields.reset_quanguan_dioment = v
end

function cls:get_reset_quanguan_dioment( ... )
	-- body
	return self.__fields.reset_quanguan_dioment
end


return cls
