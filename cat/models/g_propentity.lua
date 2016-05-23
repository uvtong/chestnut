local entitycpp = require "entitycpp"

local cls = class("g_propentity", entitycpp)

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
			name = 0,
			level = 0,
			sub_type = 0,
			pram1 = 0,
			pram2 = 0,
			icon_id = 0,
			intro = 0,
			use_type = 0,
		}

	self.__ecol_updated = {
			csv_id = 0,
			name = 0,
			level = 0,
			sub_type = 0,
			pram1 = 0,
			pram2 = 0,
			icon_id = 0,
			intro = 0,
			use_type = 0,
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

function cls:set_sub_type(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["sub_type"] = self.__ecol_updated["sub_type"] + 1
	if self.__ecol_updated["sub_type"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.sub_type = v
end

function cls:get_sub_type( ... )
	-- body
	return self.__fields.sub_type
end

function cls:set_pram1(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["pram1"] = self.__ecol_updated["pram1"] + 1
	if self.__ecol_updated["pram1"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.pram1 = v
end

function cls:get_pram1( ... )
	-- body
	return self.__fields.pram1
end

function cls:set_pram2(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["pram2"] = self.__ecol_updated["pram2"] + 1
	if self.__ecol_updated["pram2"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.pram2 = v
end

function cls:get_pram2( ... )
	-- body
	return self.__fields.pram2
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

function cls:set_intro(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["intro"] = self.__ecol_updated["intro"] + 1
	if self.__ecol_updated["intro"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.intro = v
end

function cls:get_intro( ... )
	-- body
	return self.__fields.intro
end

function cls:set_use_type(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["use_type"] = self.__ecol_updated["use_type"] + 1
	if self.__ecol_updated["use_type"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.use_type = v
end

function cls:get_use_type( ... )
	-- body
	return self.__fields.use_type
end


return cls
