local entitycpp = require "entitycpp"

local cls = class("users_ara_batentity", entitycpp)

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
			csv_id = 0,
			ser = 0,
			start_tm = 0,
			end_tm = 0,
			over = 0,
			res = 0,
		}

	self.__ecol_updated = {
			csv_id = 0,
			ser = 0,
			start_tm = 0,
			end_tm = 0,
			over = 0,
			res = 0,
		}

	for k,v in pairs(self.__head) do
		self.__fields[k] = assert(P[k], string.format("no exist %s", k))
	end
	return self
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

function cls:set_start_tm(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["start_tm"] = self.__ecol_updated["start_tm"] + 1
	if self.__ecol_updated["start_tm"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.start_tm = v
end

function cls:get_start_tm( ... )
	-- body
	return self.__fields.start_tm
end

function cls:set_end_tm(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["end_tm"] = self.__ecol_updated["end_tm"] + 1
	if self.__ecol_updated["end_tm"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.end_tm = v
end

function cls:get_end_tm( ... )
	-- body
	return self.__fields.end_tm
end

function cls:set_over(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["over"] = self.__ecol_updated["over"] + 1
	if self.__ecol_updated["over"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.over = v
end

function cls:get_over( ... )
	-- body
	return self.__fields.over
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
