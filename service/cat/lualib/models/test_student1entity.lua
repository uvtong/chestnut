local entitycpp = require "entitycpp"

local cls = class("test_student1entity", entitycpp)

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
			name = 0,
			age = 0,
			remark = 0,
			tfloat = 0,
		}

	self.__ecol_updated = {
			id = 0,
			name = 0,
			age = 0,
			remark = 0,
			tfloat = 0,
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

function cls:set_name(v, ... )
	-- body
	assert(v)
	self.__fields.name = v
end

function cls:get_name( ... )
	-- body
	return self.__fields.name
end

function cls:set_age(v, ... )
	-- body
	assert(v)
	self.__fields.age = v
end

function cls:get_age( ... )
	-- body
	return self.__fields.age
end

function cls:set_remark(v, ... )
	-- body
	assert(v)
	self.__fields.remark = v
end

function cls:get_remark( ... )
	-- body
	return self.__fields.remark
end

function cls:set_tfloat(v, ... )
	-- body
	assert(v)
	self.__fields.tfloat = v
end

function cls:get_tfloat( ... )
	-- body
	return self.__fields.tfloat
end


return cls
