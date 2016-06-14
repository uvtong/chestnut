local entitycpp = require "entitycpp"

local cls = class("g_goodsentity", entitycpp)

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
			currency_type = 0,
			currency_num = 0,
			g_prop_csv_id = 0,
			g_prop_num = 0,
			inventory_init = 0,
			cd = 0,
			icon_id = 0,
		}

	self.__ecol_updated = {
			csv_id = 0,
			currency_type = 0,
			currency_num = 0,
			g_prop_csv_id = 0,
			g_prop_num = 0,
			inventory_init = 0,
			cd = 0,
			icon_id = 0,
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

function cls:set_currency_type(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["currency_type"] = self.__ecol_updated["currency_type"] + 1
	if self.__ecol_updated["currency_type"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.currency_type = v
end

function cls:get_currency_type( ... )
	-- body
	return self.__fields.currency_type
end

function cls:set_currency_num(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["currency_num"] = self.__ecol_updated["currency_num"] + 1
	if self.__ecol_updated["currency_num"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.currency_num = v
end

function cls:get_currency_num( ... )
	-- body
	return self.__fields.currency_num
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

function cls:set_inventory_init(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["inventory_init"] = self.__ecol_updated["inventory_init"] + 1
	if self.__ecol_updated["inventory_init"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.inventory_init = v
end

function cls:get_inventory_init( ... )
	-- body
	return self.__fields.inventory_init
end

function cls:set_cd(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["cd"] = self.__ecol_updated["cd"] + 1
	if self.__ecol_updated["cd"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.cd = v
end

function cls:get_cd( ... )
	-- body
	return self.__fields.cd
end

function cls:set_icon_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["icon_id"] = self.__ecol_updated["icon_id"] + 1
	if self.__ecol_updated["icon_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.icon_id = v
end

function cls:get_icon_id( ... )
	-- body
	return self.__fields.icon_id
end


return cls
