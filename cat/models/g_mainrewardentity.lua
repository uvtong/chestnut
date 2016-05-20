local entitycpp = require "entitycpp"

local cls = class("g_mainrewardentity", entitycpp)

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
			groupid = 0,
			probid = 0,
		}

	self.__ecol_updated = {
			id = 0,
			csv_id = 0,
			groupid = 0,
			probid = 0,
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

function cls:set_groupid(v, ... )
	-- body
	assert(v)
	self.__fields.groupid = v
end

function cls:get_groupid( ... )
	-- body
	return self.__fields.groupid
end

function cls:set_probid(v, ... )
	-- body
	assert(v)
	self.__fields.probid = v
end

function cls:get_probid( ... )
	-- body
	return self.__fields.probid
end


return cls
