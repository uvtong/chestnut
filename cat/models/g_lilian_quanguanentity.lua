local entitycpp = require "entitycpp"

local cls = class("g_lilian_quanguanentity", entitycpp)

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
			csv_id = 0,
			belong_zone = 0,
			open_level = 0,
			time = 0,
			reward = 0,
			day_finish_time = 0,
			need_phy_power = 0,
			reward_exp = 0,
			trigger_event_prop = 0,
			trigger_event = 0,
		}

	self.__ecol_updated = {
			id = 0,
			csv_id = 0,
			belong_zone = 0,
			open_level = 0,
			time = 0,
			reward = 0,
			day_finish_time = 0,
			need_phy_power = 0,
			reward_exp = 0,
			trigger_event_prop = 0,
			trigger_event = 0,
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

function cls:set_belong_zone(v, ... )
	-- body
	assert(v)
	self.__fields.belong_zone = v
end

function cls:get_belong_zone( ... )
	-- body
	return self.__fields.belong_zone
end

function cls:set_open_level(v, ... )
	-- body
	assert(v)
	self.__fields.open_level = v
end

function cls:get_open_level( ... )
	-- body
	return self.__fields.open_level
end

function cls:set_time(v, ... )
	-- body
	assert(v)
	self.__fields.time = v
end

function cls:get_time( ... )
	-- body
	return self.__fields.time
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

function cls:set_day_finish_time(v, ... )
	-- body
	assert(v)
	self.__fields.day_finish_time = v
end

function cls:get_day_finish_time( ... )
	-- body
	return self.__fields.day_finish_time
end

function cls:set_need_phy_power(v, ... )
	-- body
	assert(v)
	self.__fields.need_phy_power = v
end

function cls:get_need_phy_power( ... )
	-- body
	return self.__fields.need_phy_power
end

function cls:set_reward_exp(v, ... )
	-- body
	assert(v)
	self.__fields.reward_exp = v
end

function cls:get_reward_exp( ... )
	-- body
	return self.__fields.reward_exp
end

function cls:set_trigger_event_prop(v, ... )
	-- body
	assert(v)
	self.__fields.trigger_event_prop = v
end

function cls:get_trigger_event_prop( ... )
	-- body
	return self.__fields.trigger_event_prop
end

function cls:set_trigger_event(v, ... )
	-- body
	assert(v)
	self.__fields.trigger_event = v
end

function cls:get_trigger_event( ... )
	-- body
	return self.__fields.trigger_event
end


return cls
