local entitycpp = require "entitycpp"

local cls = class("g_equipment_enhanceentity", entitycpp)

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
			g_csv_id = 0,
			csv_id = 0,
			name = 0,
			level = 0,
			combat = 0,
			defense = 0,
			critical_hit = 0,
			king = 0,
			combat_probability = 0,
			defense_probability = 0,
			critical_hit_probability = 0,
			king_probability = 0,
			enhance_success_rate = 0,
			currency_type = 0,
			currency_num = 0,
		}

	self.__ecol_updated = {
			g_csv_id = 0,
			csv_id = 0,
			name = 0,
			level = 0,
			combat = 0,
			defense = 0,
			critical_hit = 0,
			king = 0,
			combat_probability = 0,
			defense_probability = 0,
			critical_hit_probability = 0,
			king_probability = 0,
			enhance_success_rate = 0,
			currency_type = 0,
			currency_num = 0,
		}

	for k,v in pairs(self.__head) do
		self.__fields[k] = assert(P[k], string.format("no exist %s", k))
	end
	return self
end

function cls:set_g_csv_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["g_csv_id"] = self.__ecol_updated["g_csv_id"] + 1
	if self.__ecol_updated["g_csv_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.g_csv_id = v
end

function cls:get_g_csv_id( ... )
	-- body
	return self.__fields.g_csv_id
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

function cls:set_king(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["king"] = self.__ecol_updated["king"] + 1
	if self.__ecol_updated["king"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.king = v
end

function cls:get_king( ... )
	-- body
	return self.__fields.king
end

function cls:set_combat_probability(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["combat_probability"] = self.__ecol_updated["combat_probability"] + 1
	if self.__ecol_updated["combat_probability"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.combat_probability = v
end

function cls:get_combat_probability( ... )
	-- body
	return self.__fields.combat_probability
end

function cls:set_defense_probability(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["defense_probability"] = self.__ecol_updated["defense_probability"] + 1
	if self.__ecol_updated["defense_probability"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.defense_probability = v
end

function cls:get_defense_probability( ... )
	-- body
	return self.__fields.defense_probability
end

function cls:set_critical_hit_probability(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["critical_hit_probability"] = self.__ecol_updated["critical_hit_probability"] + 1
	if self.__ecol_updated["critical_hit_probability"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.critical_hit_probability = v
end

function cls:get_critical_hit_probability( ... )
	-- body
	return self.__fields.critical_hit_probability
end

function cls:set_king_probability(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["king_probability"] = self.__ecol_updated["king_probability"] + 1
	if self.__ecol_updated["king_probability"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.king_probability = v
end

function cls:get_king_probability( ... )
	-- body
	return self.__fields.king_probability
end

function cls:set_enhance_success_rate(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["enhance_success_rate"] = self.__ecol_updated["enhance_success_rate"] + 1
	if self.__ecol_updated["enhance_success_rate"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.enhance_success_rate = v
end

function cls:get_enhance_success_rate( ... )
	-- body
	return self.__fields.enhance_success_rate
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


return cls
