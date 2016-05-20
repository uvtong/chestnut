local entitycpp = require "entitycpp"

local cls = class("g_property_poolentity", entitycpp)

function cls:ctor(mgr, P, ... )
	-- body
	self.__head  = mgr.__head
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
			property_pool_id = 0,
			probability = 0,
		}

	self.__ecol_updated = {
			id = 0,
			csv_id = 0,
			property_pool_id = 0,
			probability = 0,
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

function cls:set_property_pool_id(v, ... )
	-- body
	assert(v)
	self.__fields.property_pool_id = v
end

function cls:get_property_pool_id( ... )
	-- body
	return self.__fields.property_pool_id
end

function cls:set_probability(v, ... )
	-- body
	assert(v)
	self.__fields.probability = v
end

function cls:get_probability( ... )
	-- body
	return self.__fields.probability
end


return cls
