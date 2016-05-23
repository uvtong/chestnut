local entitycpp = require "entitycpp"

local cls = class("g_shopentity", entitycpp)

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
			csv_id = 0,
			type = 0,
			num = 0,
			group_id = 0,
		}

	self.__ecol_updated = {
			csv_id = 0,
			type = 0,
			num = 0,
			group_id = 0,
		}

	for k,v in pairs(self.__head) do
		self.__fields[k] = assert(P[k])
	end
	return self
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

function cls:set_type(v, ... )
	-- body
	assert(v)
	self.__fields.type = v
end

function cls:get_type( ... )
	-- body
	return self.__fields.type
end

function cls:set_num(v, ... )
	-- body
	assert(v)
	self.__fields.num = v
end

function cls:get_num( ... )
	-- body
	return self.__fields.num
end

function cls:set_group_id(v, ... )
	-- body
	assert(v)
	self.__fields.group_id = v
end

function cls:get_group_id( ... )
	-- body
	return self.__fields.group_id
end


return cls
