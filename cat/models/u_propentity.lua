local entitycpp = require "entitycpp"

local cls = class("u_propentity", entitycpp)

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
			user_id = 0,
			csv_id = 0,
			num = 0,
			sub_type = 0,
			level = 0,
			pram1 = 0,
			pram2 = 0,
			name = 0,
			use_type = 0,
		}

	self.__ecol_updated = {
			id = 0,
			user_id = 0,
			csv_id = 0,
			num = 0,
			sub_type = 0,
			level = 0,
			pram1 = 0,
			pram2 = 0,
			name = 0,
			use_type = 0,
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

function cls:set_user_id(v, ... )
	-- body
	assert(v)
	self.__fields.user_id = v
end

function cls:get_user_id( ... )
	-- body
	return self.__fields.user_id
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

function cls:set_num(v, ... )
	-- body
	assert(v)
	self.__fields.num = v
end

function cls:get_num( ... )
	-- body
	return self.__fields.num
end

function cls:set_sub_type(v, ... )
	-- body
	assert(v)
	self.__fields.sub_type = v
end

function cls:get_sub_type( ... )
	-- body
	return self.__fields.sub_type
end

function cls:set_level(v, ... )
	-- body
	assert(v)
	self.__fields.level = v
end

function cls:get_level( ... )
	-- body
	return self.__fields.level
end

function cls:set_pram1(v, ... )
	-- body
	assert(v)
	self.__fields.pram1 = v
end

function cls:get_pram1( ... )
	-- body
	return self.__fields.pram1
end

function cls:set_pram2(v, ... )
	-- body
	assert(v)
	self.__fields.pram2 = v
end

function cls:get_pram2( ... )
	-- body
	return self.__fields.pram2
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

function cls:set_use_type(v, ... )
	-- body
	assert(v)
	self.__fields.use_type = v
end

function cls:get_use_type( ... )
	-- body
	return self.__fields.use_type
end


return cls
