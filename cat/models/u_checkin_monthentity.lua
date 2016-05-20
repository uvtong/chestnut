local entitycpp = require "entitycpp"

local cls = class("u_checkin_monthentity", entitycpp)

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
			checkin_month = 0,
			user_id = 0,
		}

	self.__ecol_updated = {
			id = 0,
			checkin_month = 0,
			user_id = 0,
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

function cls:set_checkin_month(v, ... )
	-- body
	assert(v)
	self.__fields.checkin_month = v
end

function cls:get_checkin_month( ... )
	-- body
	return self.__fields.checkin_month
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


return cls
