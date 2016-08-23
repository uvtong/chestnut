local entitycpp = require "entitycpp"

local cls = class("g_monsterentity", entitycpp)

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
			combat = 0,
			defense = 0,
			critical_hit = 0,
			blessing = 0,
			quanfaid = 0,
		}

	self.__ecol_updated = {
			csv_id = 0,
			name = 0,
			combat = 0,
			defense = 0,
			critical_hit = 0,
			blessing = 0,
			quanfaid = 0,
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

function cls:set_combat(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["combat"] = self.__ecol_updated["combat"] + 1
	if self.__ecol_updated["combat"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.combat = v
end

function cls:get_combat( ... )
	-- body
	return self.__fields.combat
end

function cls:set_defense(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["defense"] = self.__ecol_updated["defense"] + 1
	if self.__ecol_updated["defense"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.defense = v
end

function cls:get_defense( ... )
	-- body
	return self.__fields.defense
end

function cls:set_critical_hit(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["critical_hit"] = self.__ecol_updated["critical_hit"] + 1
	if self.__ecol_updated["critical_hit"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.critical_hit = v
end

function cls:get_critical_hit( ... )
	-- body
	return self.__fields.critical_hit
end

function cls:set_blessing(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["blessing"] = self.__ecol_updated["blessing"] + 1
	if self.__ecol_updated["blessing"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.blessing = v
end

function cls:get_blessing( ... )
	-- body
	return self.__fields.blessing
end

function cls:set_quanfaid(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["quanfaid"] = self.__ecol_updated["quanfaid"] + 1
	if self.__ecol_updated["quanfaid"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.quanfaid = v
end

function cls:get_quanfaid( ... )
	-- body
	return self.__fields.quanfaid
end


return cls
