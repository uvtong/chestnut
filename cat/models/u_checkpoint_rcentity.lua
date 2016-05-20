local entitycpp = require "entitycpp"

local cls = class("u_checkpoint_rcentity", entitycpp)

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
			user_id = 0,
			csv_id = 0,
			passed = 0,
			cd_starttime = 0,
			cd_finished = 0,
			cd_walk = 0,
			hanging_starttime = 0,
			hanging_walk = 0,
			hanging_drop_starttime = 0,
			hanging_drop_walk = 0,
		}

	self.__ecol_updated = {
			id = 0,
			user_id = 0,
			csv_id = 0,
			passed = 0,
			cd_starttime = 0,
			cd_finished = 0,
			cd_walk = 0,
			hanging_starttime = 0,
			hanging_walk = 0,
			hanging_drop_starttime = 0,
			hanging_drop_walk = 0,
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

function cls:set_user_id(v, ... )
	-- body
	assert(v)
	self.__fields.user_id = v
end

function cls:get_user_id( ... )
	-- body
	return self.__fields.user_id
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

function cls:set_passed(v, ... )
	-- body
	assert(v)
	self.__fields.passed = v
end

function cls:get_passed( ... )
	-- body
	return self.__fields.passed
end

function cls:set_cd_starttime(v, ... )
	-- body
	assert(v)
	self.__fields.cd_starttime = v
end

function cls:get_cd_starttime( ... )
	-- body
	return self.__fields.cd_starttime
end

function cls:set_cd_finished(v, ... )
	-- body
	assert(v)
	self.__fields.cd_finished = v
end

function cls:get_cd_finished( ... )
	-- body
	return self.__fields.cd_finished
end

function cls:set_cd_walk(v, ... )
	-- body
	assert(v)
	self.__fields.cd_walk = v
end

function cls:get_cd_walk( ... )
	-- body
	return self.__fields.cd_walk
end

function cls:set_hanging_starttime(v, ... )
	-- body
	assert(v)
	self.__fields.hanging_starttime = v
end

function cls:get_hanging_starttime( ... )
	-- body
	return self.__fields.hanging_starttime
end

function cls:set_hanging_walk(v, ... )
	-- body
	assert(v)
	self.__fields.hanging_walk = v
end

function cls:get_hanging_walk( ... )
	-- body
	return self.__fields.hanging_walk
end

function cls:set_hanging_drop_starttime(v, ... )
	-- body
	assert(v)
	self.__fields.hanging_drop_starttime = v
end

function cls:get_hanging_drop_starttime( ... )
	-- body
	return self.__fields.hanging_drop_starttime
end

function cls:set_hanging_drop_walk(v, ... )
	-- body
	assert(v)
	self.__fields.hanging_drop_walk = v
end

function cls:get_hanging_drop_walk( ... )
	-- body
	return self.__fields.hanging_drop_walk
end


return cls
