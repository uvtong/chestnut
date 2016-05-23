local entitycpp = require "entitycpp"

local cls = class("u_ara_batentity", entitycpp)

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
			date = 0,
			ser = 0,
			start_time = 0,
			is_over = 0,
			res = 0,
		}

	self.__ecol_updated = {
			id = 0,
			user_id = 0,
			csv_id = 0,
			date = 0,
			ser = 0,
			start_time = 0,
			is_over = 0,
			res = 0,
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

function cls:set_date(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["date"] = self.__ecol_updated["date"] + 1
	if self.__ecol_updated["date"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.date = v
end

function cls:get_date( ... )
	-- body
	return self.__fields.date
end

function cls:set_ser(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["ser"] = self.__ecol_updated["ser"] + 1
	if self.__ecol_updated["ser"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.ser = v
end

function cls:get_ser( ... )
	-- body
	return self.__fields.ser
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

function cls:set_is_over(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["is_over"] = self.__ecol_updated["is_over"] + 1
	if self.__ecol_updated["is_over"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.is_over = v
end

function cls:get_is_over( ... )
	-- body
	return self.__fields.is_over
end

function cls:set_res(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["res"] = self.__ecol_updated["res"] + 1
	if self.__ecol_updated["res"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.res = v
end

function cls:get_res( ... )
	-- body
	return self.__fields.res
end


return cls
