local entitycpp = require "entitycpp"

local cls = class("u_checkinentity", entitycpp)

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
			user_id = 0,
			u_checkin_time = 0,
			ifcheck_in = 0,
		}

	self.__ecol_updated = {
			id = 0,
			csv_id = 0,
			user_id = 0,
			u_checkin_time = 0,
			ifcheck_in = 0,
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

function cls:set_user_id(v, ... )
	-- body
	assert(v)
	self.__fields.user_id = v
end

function cls:get_user_id( ... )
	-- body
	return self.__fields.user_id
end

function cls:set_u_checkin_time(v, ... )
	-- body
	assert(v)
	self.__fields.u_checkin_time = v
end

function cls:get_u_checkin_time( ... )
	-- body
	return self.__fields.u_checkin_time
end

function cls:set_ifcheck_in(v, ... )
	-- body
	assert(v)
	self.__fields.ifcheck_in = v
end

function cls:get_ifcheck_in( ... )
	-- body
	return self.__fields.ifcheck_in
end


return cls
