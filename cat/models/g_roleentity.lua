local entitycpp = require "entitycpp"

local cls = class("g_roleentity", entitycpp)

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
			star = 0,
			name = 0,
			us_prop_csv_id = 0,
		}

	self.__ecol_updated = {
			csv_id = 0,
			star = 0,
			name = 0,
			us_prop_csv_id = 0,
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

function cls:set_star(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["star"] = self.__ecol_updated["star"] + 1
	if self.__ecol_updated["star"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.star = v
end

function cls:get_star( ... )
	-- body
	return self.__fields.star
end

function cls:set_name(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["name"] = self.__ecol_updated["name"] + 1
	if self.__ecol_updated["name"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.name = v
end

function cls:get_name( ... )
	-- body
	return self.__fields.name
end

function cls:set_us_prop_csv_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["us_prop_csv_id"] = self.__ecol_updated["us_prop_csv_id"] + 1
	if self.__ecol_updated["us_prop_csv_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.us_prop_csv_id = v
end

function cls:get_us_prop_csv_id( ... )
	-- body
	return self.__fields.us_prop_csv_id
end


return cls
