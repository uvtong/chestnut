local entitycpp = require "entitycpp"

local cls = class("u_kungfuentity", entitycpp)

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
			level = 0,
			type = 0,
			sp_id = 0,
			g_csv_id = 0,
		}

	self.__ecol_updated = {
			id = 0,
			user_id = 0,
			csv_id = 0,
			level = 0,
			type = 0,
			sp_id = 0,
			g_csv_id = 0,
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

function cls:set_level(v, ... )
	-- body
	assert(v)
	self.__fields.level = v
end

function cls:get_level( ... )
	-- body
	return self.__fields.level
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

function cls:set_sp_id(v, ... )
	-- body
	assert(v)
	self.__fields.sp_id = v
end

function cls:get_sp_id( ... )
	-- body
	return self.__fields.sp_id
end

function cls:set_g_csv_id(v, ... )
	-- body
	assert(v)
	self.__fields.g_csv_id = v
end

function cls:get_g_csv_id( ... )
	-- body
	return self.__fields.g_csv_id
end


return cls
