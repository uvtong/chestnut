local entitycpp = require "entitycpp"

local cls = class("g_uidentity", entitycpp)

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
			entropy = 0,
		}

	self.__ecol_updated = {
			csv_id = 0,
			entropy = 0,
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

function cls:set_entropy(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["entropy"] = self.__ecol_updated["entropy"] + 1
	if self.__ecol_updated["entropy"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.entropy = v
end

function cls:get_entropy( ... )
	-- body
	return self.__fields.entropy
end


return cls
