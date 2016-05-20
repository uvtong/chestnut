local entitycpp = require "entitycpp"

local cls = class("g_lilian_levelentity", entitycpp)

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
			phy_power = 0,
			experience = 0,
			queue = 0,
			dec_lilian_time = 0,
			dec_weikun_time = 0,
		}

	self.__ecol_updated = {
			id = 0,
			csv_id = 0,
			phy_power = 0,
			experience = 0,
			queue = 0,
			dec_lilian_time = 0,
			dec_weikun_time = 0,
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

function cls:set_phy_power(v, ... )
	-- body
	assert(v)
	self.__fields.phy_power = v
end

function cls:get_phy_power( ... )
	-- body
	return self.__fields.phy_power
end

function cls:set_experience(v, ... )
	-- body
	assert(v)
	self.__fields.experience = v
end

function cls:get_experience( ... )
	-- body
	return self.__fields.experience
end

function cls:set_queue(v, ... )
	-- body
	assert(v)
	self.__fields.queue = v
end

function cls:get_queue( ... )
	-- body
	return self.__fields.queue
end

function cls:set_dec_lilian_time(v, ... )
	-- body
	assert(v)
	self.__fields.dec_lilian_time = v
end

function cls:get_dec_lilian_time( ... )
	-- body
	return self.__fields.dec_lilian_time
end

function cls:set_dec_weikun_time(v, ... )
	-- body
	assert(v)
	self.__fields.dec_weikun_time = v
end

function cls:get_dec_weikun_time( ... )
	-- body
	return self.__fields.dec_weikun_time
end


return cls
