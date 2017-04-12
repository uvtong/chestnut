local entitycpp = require "entitycpp"

local cls = class("g_checkin_totalentity", entitycpp)

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
			totalamount = 0,
			prop_id_num = 0,
		}

	self.__ecol_updated = {
			csv_id = 0,
			totalamount = 0,
			prop_id_num = 0,
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

function cls:set_totalamount(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["totalamount"] = self.__ecol_updated["totalamount"] + 1
	if self.__ecol_updated["totalamount"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.totalamount = v
end

function cls:get_totalamount( ... )
	-- body
	return self.__fields.totalamount
end

function cls:set_prop_id_num(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["prop_id_num"] = self.__ecol_updated["prop_id_num"] + 1
	if self.__ecol_updated["prop_id_num"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.prop_id_num = v
end

function cls:get_prop_id_num( ... )
	-- body
	return self.__fields.prop_id_num
end


return cls
