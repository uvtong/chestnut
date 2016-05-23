local entitycpp = require "entitycpp"

local cls = class("g_lilian_invitationentity", entitycpp)

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
			name = 0,
			reward = 0,
		}

	self.__ecol_updated = {
			csv_id = 0,
			name = 0,
			reward = 0,
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

function cls:set_name(v, ... )
	-- body
	assert(v)
	self.__fields.name = v
end

function cls:get_name( ... )
	-- body
	return self.__fields.name
end

function cls:set_reward(v, ... )
	-- body
	assert(v)
	self.__fields.reward = v
end

function cls:get_reward( ... )
	-- body
	return self.__fields.reward
end


return cls
