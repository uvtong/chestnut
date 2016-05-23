local entitycpp = require "entitycpp"

local cls = class("u_lilian_subentity", entitycpp)

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

function cls:set_first_lilian_time(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["first_lilian_time"] = self.__ecol_updated["first_lilian_time"] + 1
	if self.__ecol_updated["first_lilian_time"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.first_lilian_time = v
end

function cls:get_first_lilian_time( ... )
	-- body
	return self.__fields.first_lilian_time
end

function cls:set_start_time(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["start_time"] = self.__ecol_updated["start_time"] + 1
	if self.__ecol_updated["start_time"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.start_time = v
end

function cls:get_start_time( ... )
	-- body
	return self.__fields.start_time
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

function cls:set_used_queue_num(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["used_queue_num"] = self.__ecol_updated["used_queue_num"] + 1
	if self.__ecol_updated["used_queue_num"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.used_queue_num = v
end

function cls:get_used_queue_num( ... )
	-- body
	return self.__fields.used_queue_num
end

function cls:set_end_lilian_time(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["end_lilian_time"] = self.__ecol_updated["end_lilian_time"] + 1
	if self.__ecol_updated["end_lilian_time"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.end_lilian_time = v
end

function cls:get_end_lilian_time( ... )
	-- body
	return self.__fields.end_lilian_time
end


return cls
