local entitycpp = require "entitycpp"

local cls = class("g_lilian_evententity", entitycpp)

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
			cd_time = 0,
			description = 0,
			reward = 0,
		}

	self.__ecol_updated = {
			csv_id = 0,
			cd_time = 0,
			description = 0,
			reward = 0,
		}

	for k,v in pairs(self.__head) do
		self.__fields[k] = assert(P[k], string.format("no exist %s", k))
	end
	return self
end

function cls:set_csv_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["csv_id"] = self.__ecol_updated["csv_id"] + 1
	if self.__ecol_updated["csv_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.csv_id = v
end

function cls:get_csv_id( ... )
	-- body
	return self.__fields.csv_id
end

function cls:set_cd_time(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["cd_time"] = self.__ecol_updated["cd_time"] + 1
	if self.__ecol_updated["cd_time"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.cd_time = v
end

function cls:get_cd_time( ... )
	-- body
	return self.__fields.cd_time
end

function cls:set_description(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["description"] = self.__ecol_updated["description"] + 1
	if self.__ecol_updated["description"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.description = v
end

function cls:get_description( ... )
	-- body
	return self.__fields.description
end

function cls:set_reward(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["reward"] = self.__ecol_updated["reward"] + 1
	if self.__ecol_updated["reward"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.reward = v
end

function cls:get_reward( ... )
	-- body
	return self.__fields.reward
end


return cls
