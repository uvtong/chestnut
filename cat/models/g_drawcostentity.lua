local entitycpp = require "entitycpp"

local cls = class("g_drawcostentity", entitycpp)

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
			cointype = 0,
			price = 0,
			cdtime = 0,
		}

	self.__ecol_updated = {
			csv_id = 0,
			cointype = 0,
			price = 0,
			cdtime = 0,
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

function cls:set_cointype(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["cointype"] = self.__ecol_updated["cointype"] + 1
	if self.__ecol_updated["cointype"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.cointype = v
end

function cls:get_cointype( ... )
	-- body
	return self.__fields.cointype
end

function cls:set_price(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["price"] = self.__ecol_updated["price"] + 1
	if self.__ecol_updated["price"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.price = v
end

function cls:get_price( ... )
	-- body
	return self.__fields.price
end

function cls:set_cdtime(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["cdtime"] = self.__ecol_updated["cdtime"] + 1
	if self.__ecol_updated["cdtime"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.cdtime = v
end

function cls:get_cdtime( ... )
	-- body
	return self.__fields.cdtime
end


return cls
