local entitycpp = require "entitycpp"

local cls = class("g_checkpoint_chapterentity", entitycpp)

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
			level = 0,
			name = 0,
			type0_max = 0,
			type1_max = 0,
			type2_max = 0,
		}

	self.__ecol_updated = {
			csv_id = 0,
			level = 0,
			name = 0,
			type0_max = 0,
			type1_max = 0,
			type2_max = 0,
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

function cls:set_level(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["level"] = self.__ecol_updated["level"] + 1
	if self.__ecol_updated["level"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.level = v
end

function cls:get_level( ... )
	-- body
	return self.__fields.level
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

function cls:set_type0_max(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["type0_max"] = self.__ecol_updated["type0_max"] + 1
	if self.__ecol_updated["type0_max"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.type0_max = v
end

function cls:get_type0_max( ... )
	-- body
	return self.__fields.type0_max
end

function cls:set_type1_max(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["type1_max"] = self.__ecol_updated["type1_max"] + 1
	if self.__ecol_updated["type1_max"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.type1_max = v
end

function cls:get_type1_max( ... )
	-- body
	return self.__fields.type1_max
end

function cls:set_type2_max(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["type2_max"] = self.__ecol_updated["type2_max"] + 1
	if self.__ecol_updated["type2_max"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.type2_max = v
end

function cls:get_type2_max( ... )
	-- body
	return self.__fields.type2_max
end


return cls
