local entitycpp = require "entitycpp"

local cls = class("g_checkinentity", entitycpp)

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
			month = 0,
			count = 0,
			g_prop_csv_id = 0,
			g_prop_num = 0,
			vip = 0,
			vip_g_prop_csv_id = 0,
			vip_g_prop_num = 0,
		}

	self.__ecol_updated = {
			csv_id = 0,
			month = 0,
			count = 0,
			g_prop_csv_id = 0,
			g_prop_num = 0,
			vip = 0,
			vip_g_prop_csv_id = 0,
			vip_g_prop_num = 0,
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

function cls:set_month(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["month"] = self.__ecol_updated["month"] + 1
	if self.__ecol_updated["month"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.month = v
end

function cls:get_month( ... )
	-- body
	return self.__fields.month
end

function cls:set_count(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["count"] = self.__ecol_updated["count"] + 1
	if self.__ecol_updated["count"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.count = v
end

function cls:get_count( ... )
	-- body
	return self.__fields.count
end

function cls:set_g_prop_csv_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["g_prop_csv_id"] = self.__ecol_updated["g_prop_csv_id"] + 1
	if self.__ecol_updated["g_prop_csv_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.g_prop_csv_id = v
end

function cls:get_g_prop_csv_id( ... )
	-- body
	return self.__fields.g_prop_csv_id
end

function cls:set_g_prop_num(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["g_prop_num"] = self.__ecol_updated["g_prop_num"] + 1
	if self.__ecol_updated["g_prop_num"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.g_prop_num = v
end

function cls:get_g_prop_num( ... )
	-- body
	return self.__fields.g_prop_num
end

function cls:set_vip(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["vip"] = self.__ecol_updated["vip"] + 1
	if self.__ecol_updated["vip"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.vip = v
end

function cls:get_vip( ... )
	-- body
	return self.__fields.vip
end

function cls:set_vip_g_prop_csv_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["vip_g_prop_csv_id"] = self.__ecol_updated["vip_g_prop_csv_id"] + 1
	if self.__ecol_updated["vip_g_prop_csv_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.vip_g_prop_csv_id = v
end

function cls:get_vip_g_prop_csv_id( ... )
	-- body
	return self.__fields.vip_g_prop_csv_id
end

function cls:set_vip_g_prop_num(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["vip_g_prop_num"] = self.__ecol_updated["vip_g_prop_num"] + 1
	if self.__ecol_updated["vip_g_prop_num"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.vip_g_prop_num = v
end

function cls:get_vip_g_prop_num( ... )
	-- body
	return self.__fields.vip_g_prop_num
end


return cls
