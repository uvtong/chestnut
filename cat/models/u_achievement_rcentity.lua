local entitycpp = require "entitycpp"

local cls = class("u_achievement_rcentity", entitycpp)

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
			user_id = 0,
			csv_id = 0,
			finished = 0,
			reward_collected = 0,
			is_unlock = 0,
		}

	self.__ecol_updated = {
			id = 0,
			user_id = 0,
			csv_id = 0,
			finished = 0,
			reward_collected = 0,
			is_unlock = 0,
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
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.id = v
end

function cls:get_id( ... )
	-- body
	return self.__fields.id
end

function cls:set_user_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["user_id"] = self.__ecol_updated["user_id"] + 1
	if self.__ecol_updated["user_id"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.user_id = v
end

function cls:get_user_id( ... )
	-- body
	return self.__fields.user_id
end

function cls:set_csv_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["csv_id"] = self.__ecol_updated["csv_id"] + 1
	if self.__ecol_updated["csv_id"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.csv_id = v
end

function cls:get_csv_id( ... )
	-- body
	return self.__fields.csv_id
end

function cls:set_finished(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["finished"] = self.__ecol_updated["finished"] + 1
	if self.__ecol_updated["finished"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.finished = v
end

function cls:get_finished( ... )
	-- body
	return self.__fields.finished
end

function cls:set_reward_collected(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["reward_collected"] = self.__ecol_updated["reward_collected"] + 1
	if self.__ecol_updated["reward_collected"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.reward_collected = v
end

function cls:get_reward_collected( ... )
	-- body
	return self.__fields.reward_collected
end

function cls:set_is_unlock(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["is_unlock"] = self.__ecol_updated["is_unlock"] + 1
	if self.__ecol_updated["is_unlock"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.is_unlock = v
end

function cls:get_is_unlock( ... )
	-- body
	return self.__fields.is_unlock
end


return cls