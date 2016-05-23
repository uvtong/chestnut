local entitycpp = require "entitycpp"

local cls = class("g_achievemententity", entitycpp)

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
			type = 0,
			name = 0,
			c_num = 0,
			describe = 0,
			icon_id = 0,
			reward = 0,
			star = 0,
			unlock_next_csv_id = 0,
		}

	self.__ecol_updated = {
			csv_id = 0,
			type = 0,
			name = 0,
			c_num = 0,
			describe = 0,
			icon_id = 0,
			reward = 0,
			star = 0,
			unlock_next_csv_id = 0,
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

function cls:set_type(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["type"] = self.__ecol_updated["type"] + 1
	if self.__ecol_updated["type"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.type = v
end

function cls:get_type( ... )
	-- body
	return self.__fields.type
end

function cls:set_name(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["name"] = self.__ecol_updated["name"] + 1
	if self.__ecol_updated["name"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.name = v
end

function cls:get_name( ... )
	-- body
	return self.__fields.name
end

function cls:set_c_num(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["c_num"] = self.__ecol_updated["c_num"] + 1
	if self.__ecol_updated["c_num"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.c_num = v
end

function cls:get_c_num( ... )
	-- body
	return self.__fields.c_num
end

function cls:set_describe(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["describe"] = self.__ecol_updated["describe"] + 1
	if self.__ecol_updated["describe"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.describe = v
end

function cls:get_describe( ... )
	-- body
	return self.__fields.describe
end

function cls:set_icon_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["icon_id"] = self.__ecol_updated["icon_id"] + 1
	if self.__ecol_updated["icon_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.icon_id = v
end

function cls:get_icon_id( ... )
	-- body
	return self.__fields.icon_id
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

function cls:set_star(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["star"] = self.__ecol_updated["star"] + 1
	if self.__ecol_updated["star"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.star = v
end

function cls:get_star( ... )
	-- body
	return self.__fields.star
end

function cls:set_unlock_next_csv_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["unlock_next_csv_id"] = self.__ecol_updated["unlock_next_csv_id"] + 1
	if self.__ecol_updated["unlock_next_csv_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.unlock_next_csv_id = v
end

function cls:get_unlock_next_csv_id( ... )
	-- body
	return self.__fields.unlock_next_csv_id
end


return cls
