local entitycpp = require "entitycpp"

local cls = class("u_exerciseentity", entitycpp)

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
			exercise_time = 0,
			exercise_type = 0,
			time_length = 0,
		}

	self.__ecol_updated = {
			id = 0,
			user_id = 0,
			exercise_time = 0,
			exercise_type = 0,
			time_length = 0,
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

function cls:set_user_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["user_id"] = self.__ecol_updated["user_id"] + 1
	if self.__ecol_updated["user_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.user_id = v
end

function cls:get_user_id( ... )
	-- body
	return self.__fields.user_id
end

function cls:set_exercise_time(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["exercise_time"] = self.__ecol_updated["exercise_time"] + 1
	if self.__ecol_updated["exercise_time"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.exercise_time = v
end

function cls:get_exercise_time( ... )
	-- body
	return self.__fields.exercise_time
end

function cls:set_exercise_type(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["exercise_type"] = self.__ecol_updated["exercise_type"] + 1
	if self.__ecol_updated["exercise_type"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.exercise_type = v
end

function cls:get_exercise_type( ... )
	-- body
	return self.__fields.exercise_type
end

function cls:set_time_length(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["time_length"] = self.__ecol_updated["time_length"] + 1
	if self.__ecol_updated["time_length"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.time_length = v
end

function cls:get_time_length( ... )
	-- body
	return self.__fields.time_length
end


return cls
