local entitycpp = require "entitycpp"

local cls = class("accountentity", entitycpp)

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
			user = 0,
			password = 0,
			signuptime = 0,
			csv_id = 0,
		}

	self.__ecol_updated = {
			id = 0,
			user = 0,
			password = 0,
			signuptime = 0,
			csv_id = 0,
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

function cls:set_user(v, ... )
	-- body
	assert(v)
	self.__fields.user = v
end

function cls:get_user( ... )
	-- body
	return self.__fields.user
end

function cls:set_password(v, ... )
	-- body
	assert(v)
	self.__fields.password = v
end

function cls:get_password( ... )
	-- body
	return self.__fields.password
end

function cls:set_signuptime(v, ... )
	-- body
	assert(v)
	self.__fields.signuptime = v
end

function cls:get_signuptime( ... )
	-- body
	return self.__fields.signuptime
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


return cls
