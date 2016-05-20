local entitycpp = require "entitycpp"

local cls = class("u_recharge_recordentity", entitycpp)

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
			dt = 0,
		}

	self.__ecol_updated = {
			id = 0,
			user_id = 0,
			csv_id = 0,
			num = 0,
			dt = 0,
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

function cls:set_dt(v, ... )
	-- body
	assert(v)
	self.__fields.dt = v
end

function cls:get_dt( ... )
	-- body
	return self.__fields.dt
end


return cls
