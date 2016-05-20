local entitycpp = require "entitycpp"

local cls = class("u_lilian_subentity", entitycpp)

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
			first_lilian_time = 0,
			start_time = 0,
			update_time = 0,
			used_queue_num = 0,
			end_lilian_time = 0,
		}

	self.__ecol_updated = {
			id = 0,
			csv_id = 0,
			first_lilian_time = 0,
			start_time = 0,
			update_time = 0,
			used_queue_num = 0,
			end_lilian_time = 0,
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

function cls:set_first_lilian_time(v, ... )
	-- body
	assert(v)
	self.__fields.first_lilian_time = v
end

function cls:get_first_lilian_time( ... )
	-- body
	return self.__fields.first_lilian_time
end

function cls:set_start_time(v, ... )
	-- body
	assert(v)
	self.__fields.start_time = v
end

function cls:get_start_time( ... )
	-- body
	return self.__fields.start_time
end

function cls:set_update_time(v, ... )
	-- body
	assert(v)
	self.__fields.update_time = v
end

function cls:get_update_time( ... )
	-- body
	return self.__fields.update_time
end

function cls:set_used_queue_num(v, ... )
	-- body
	assert(v)
	self.__fields.used_queue_num = v
end

function cls:get_used_queue_num( ... )
	-- body
	return self.__fields.used_queue_num
end

function cls:set_end_lilian_time(v, ... )
	-- body
	assert(v)
	self.__fields.end_lilian_time = v
end

function cls:get_end_lilian_time( ... )
	-- body
	return self.__fields.end_lilian_time
end


return cls
