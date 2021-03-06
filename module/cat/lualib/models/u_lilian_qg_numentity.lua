local entitycpp = require "entitycpp"

local cls = class("u_lilian_qg_numentity", entitycpp)

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
			user_id = 0,
			start_time = 0,
			end_time = 0,
			num = 0,
			quanguan_id = 0,
			reset_num = 0,
		}

	self.__ecol_updated = {
			id = 0,
			csv_id = 0,
			user_id = 0,
			start_time = 0,
			end_time = 0,
			num = 0,
			quanguan_id = 0,
			reset_num = 0,
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

function cls:set_end_time(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["end_time"] = self.__ecol_updated["end_time"] + 1
	if self.__ecol_updated["end_time"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.end_time = v
end

function cls:get_end_time( ... )
	-- body
	return self.__fields.end_time
end

function cls:set_num(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["num"] = self.__ecol_updated["num"] + 1
	if self.__ecol_updated["num"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.num = v
end

function cls:get_num( ... )
	-- body
	return self.__fields.num
end

function cls:set_quanguan_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["quanguan_id"] = self.__ecol_updated["quanguan_id"] + 1
	if self.__ecol_updated["quanguan_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.quanguan_id = v
end

function cls:get_quanguan_id( ... )
	-- body
	return self.__fields.quanguan_id
end

function cls:set_reset_num(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["reset_num"] = self.__ecol_updated["reset_num"] + 1
	if self.__ecol_updated["reset_num"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.reset_num = v
end

function cls:get_reset_num( ... )
	-- body
	return self.__fields.reset_num
end


return cls
