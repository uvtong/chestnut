local entitycpp = require "entitycpp"

local cls = class("g_kungfuentity", entitycpp)

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
			name = 0,
			csv_id = 0,
			level = 0,
			iconid = 0,
			skill_descp = 0,
			skill_effect = 0,
			type = 0,
			harm_type = 0,
			arise_probability = 0,
			arise_count = 0,
			arise_type = 0,
			arise_param = 0,
			attack_type = 0,
			effect_percent = 0,
			addition_effect_type = 0,
			addition_prog = 0,
			equip_buff_id = 0,
			buff_id = 0,
			prop_csv_id = 0,
			prop_num = 0,
			currency_type = 0,
			currency_num = 0,
		}

	self.__ecol_updated = {
			g_csv_id = 0,
			name = 0,
			csv_id = 0,
			level = 0,
			iconid = 0,
			skill_descp = 0,
			skill_effect = 0,
			type = 0,
			harm_type = 0,
			arise_probability = 0,
			arise_count = 0,
			arise_type = 0,
			arise_param = 0,
			attack_type = 0,
			effect_percent = 0,
			addition_effect_type = 0,
			addition_prog = 0,
			equip_buff_id = 0,
			buff_id = 0,
			prop_csv_id = 0,
			prop_num = 0,
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

function cls:set_iconid(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["iconid"] = self.__ecol_updated["iconid"] + 1
	if self.__ecol_updated["iconid"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.iconid = v
end

function cls:get_iconid( ... )
	-- body
	return self.__fields.iconid
end

function cls:set_skill_descp(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["skill_descp"] = self.__ecol_updated["skill_descp"] + 1
	if self.__ecol_updated["skill_descp"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.skill_descp = v
end

function cls:get_skill_descp( ... )
	-- body
	return self.__fields.skill_descp
end

function cls:set_skill_effect(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["skill_effect"] = self.__ecol_updated["skill_effect"] + 1
	if self.__ecol_updated["skill_effect"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.skill_effect = v
end

function cls:get_skill_effect( ... )
	-- body
	return self.__fields.skill_effect
end

function cls:set_type(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["type"] = self.__ecol_updated["type"] + 1
	if self.__ecol_updated["type"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.type = v
end

function cls:get_type( ... )
	-- body
	return self.__fields.type
end

function cls:set_harm_type(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["harm_type"] = self.__ecol_updated["harm_type"] + 1
	if self.__ecol_updated["harm_type"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.harm_type = v
end

function cls:get_harm_type( ... )
	-- body
	return self.__fields.harm_type
end

function cls:set_arise_probability(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["arise_probability"] = self.__ecol_updated["arise_probability"] + 1
	if self.__ecol_updated["arise_probability"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.arise_probability = v
end

function cls:get_arise_probability( ... )
	-- body
	return self.__fields.arise_probability
end

function cls:set_arise_count(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["arise_count"] = self.__ecol_updated["arise_count"] + 1
	if self.__ecol_updated["arise_count"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.arise_count = v
end

function cls:get_arise_count( ... )
	-- body
	return self.__fields.arise_count
end

function cls:set_arise_type(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["arise_type"] = self.__ecol_updated["arise_type"] + 1
	if self.__ecol_updated["arise_type"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.arise_type = v
end

function cls:get_arise_type( ... )
	-- body
	return self.__fields.arise_type
end

function cls:set_arise_param(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["arise_param"] = self.__ecol_updated["arise_param"] + 1
	if self.__ecol_updated["arise_param"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.arise_param = v
end

function cls:get_arise_param( ... )
	-- body
	return self.__fields.arise_param
end

function cls:set_attack_type(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["attack_type"] = self.__ecol_updated["attack_type"] + 1
	if self.__ecol_updated["attack_type"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.attack_type = v
end

function cls:get_attack_type( ... )
	-- body
	return self.__fields.attack_type
end

function cls:set_effect_percent(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["effect_percent"] = self.__ecol_updated["effect_percent"] + 1
	if self.__ecol_updated["effect_percent"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.effect_percent = v
end

function cls:get_effect_percent( ... )
	-- body
	return self.__fields.effect_percent
end

function cls:set_addition_effect_type(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["addition_effect_type"] = self.__ecol_updated["addition_effect_type"] + 1
	if self.__ecol_updated["addition_effect_type"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.addition_effect_type = v
end

function cls:get_addition_effect_type( ... )
	-- body
	return self.__fields.addition_effect_type
end

function cls:set_addition_prog(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["addition_prog"] = self.__ecol_updated["addition_prog"] + 1
	if self.__ecol_updated["addition_prog"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.addition_prog = v
end

function cls:get_addition_prog( ... )
	-- body
	return self.__fields.addition_prog
end

function cls:set_equip_buff_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["equip_buff_id"] = self.__ecol_updated["equip_buff_id"] + 1
	if self.__ecol_updated["equip_buff_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.equip_buff_id = v
end

function cls:get_equip_buff_id( ... )
	-- body
	return self.__fields.equip_buff_id
end

function cls:set_buff_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["buff_id"] = self.__ecol_updated["buff_id"] + 1
	if self.__ecol_updated["buff_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.buff_id = v
end

function cls:get_buff_id( ... )
	-- body
	return self.__fields.buff_id
end

function cls:set_prop_csv_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["prop_csv_id"] = self.__ecol_updated["prop_csv_id"] + 1
	if self.__ecol_updated["prop_csv_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.prop_csv_id = v
end

function cls:get_prop_csv_id( ... )
	-- body
	return self.__fields.prop_csv_id
end

function cls:set_prop_num(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["prop_num"] = self.__ecol_updated["prop_num"] + 1
	if self.__ecol_updated["prop_num"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.prop_num = v
end

function cls:get_prop_num( ... )
	-- body
	return self.__fields.prop_num
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
