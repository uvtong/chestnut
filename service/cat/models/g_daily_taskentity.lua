local entitycpp = require "entitycpp"

local cls = class("g_daily_taskentity", entitycpp)

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
			update_time = 0,
			type = 0,
			task_name = 0,
			cost_amount = 0,
			iconid = 0,
			basic_reward = 0,
			levelup_reward = 0,
			level_up = 0,
			cost_id = 0,
		}

	self.__ecol_updated = {
			id = 0,
			update_time = 0,
			type = 0,
			task_name = 0,
			cost_amount = 0,
			iconid = 0,
			basic_reward = 0,
			levelup_reward = 0,
			level_up = 0,
			cost_id = 0,
		}

	for k,v in pairs(self.__head) do
		self.__fields[k] = assert(P[k], string.format("no exist %s", k))
	end
	return self
end

function cls:set_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["id"] = self.__ecol_updated["id"] + 1
	if self.__ecol_updated["id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.id = v
end

function cls:get_id( ... )
	-- body
	return self.__fields.id
end

function cls:set_update_time(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["update_time"] = self.__ecol_updated["update_time"] + 1
	if self.__ecol_updated["update_time"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.update_time = v
end

function cls:get_update_time( ... )
	-- body
	return self.__fields.update_time
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

function cls:set_task_name(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["task_name"] = self.__ecol_updated["task_name"] + 1
	if self.__ecol_updated["task_name"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.task_name = v
end

function cls:get_task_name( ... )
	-- body
	return self.__fields.task_name
end

function cls:set_cost_amount(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["cost_amount"] = self.__ecol_updated["cost_amount"] + 1
	if self.__ecol_updated["cost_amount"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.cost_amount = v
end

function cls:get_cost_amount( ... )
	-- body
	return self.__fields.cost_amount
end

function cls:set_iconid(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["iconid"] = self.__ecol_updated["iconid"] + 1
	if self.__ecol_updated["iconid"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.iconid = v
end

function cls:get_iconid( ... )
	-- body
	return self.__fields.iconid
end

function cls:set_basic_reward(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["basic_reward"] = self.__ecol_updated["basic_reward"] + 1
	if self.__ecol_updated["basic_reward"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.basic_reward = v
end

function cls:get_basic_reward( ... )
	-- body
	return self.__fields.basic_reward
end

function cls:set_levelup_reward(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["levelup_reward"] = self.__ecol_updated["levelup_reward"] + 1
	if self.__ecol_updated["levelup_reward"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.levelup_reward = v
end

function cls:get_levelup_reward( ... )
	-- body
	return self.__fields.levelup_reward
end

function cls:set_level_up(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["level_up"] = self.__ecol_updated["level_up"] + 1
	if self.__ecol_updated["level_up"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.level_up = v
end

function cls:get_level_up( ... )
	-- body
	return self.__fields.level_up
end

function cls:set_cost_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["cost_id"] = self.__ecol_updated["cost_id"] + 1
	if self.__ecol_updated["cost_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.cost_id = v
end

function cls:get_cost_id( ... )
	-- body
	return self.__fields.cost_id
end


return cls
