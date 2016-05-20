local entitycpp = require "entitycpp"

local cls = class("g_lilian_evententity", entitycpp)

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
			cd_time = 0,
			description = 0,
			reward = 0,
		}

	self.__ecol_updated = {
			id = 0,
			csv_id = 0,
			cd_time = 0,
			description = 0,
			reward = 0,
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

function cls:set_cd_time(v, ... )
	-- body
	assert(v)
	self.__fields.cd_time = v
end

function cls:get_cd_time( ... )
	-- body
	return self.__fields.cd_time
end

function cls:set_description(v, ... )
	-- body
	assert(v)
	self.__fields.description = v
end

function cls:get_description( ... )
	-- body
	return self.__fields.description
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
