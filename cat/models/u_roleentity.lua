local entitycpp = require "entitycpp"

local cls = class("u_roleentity", entitycpp)

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
			id = 0,
			user_id = 0,
			csv_id = 0,
			name = 0,
			star = 0,
			us_prop_csv_id = 0,
			us_prop_num = 0,
			sharp = 0,
			skill_csv_id = 0,
			gather_buffer_id = 0,
			battle_buffer_id = 0,
			k_csv_id1 = 0,
			k_csv_id2 = 0,
			k_csv_id3 = 0,
			k_csv_id4 = 0,
			k_csv_id5 = 0,
			k_csv_id6 = 0,
			k_csv_id7 = 0,
			property_id1 = 0,
			value1 = 0,
			property_id2 = 0,
			value2 = 0,
			property_id3 = 0,
			value3 = 0,
			property_id4 = 0,
			value4 = 0,
			property_id5 = 0,
			value5 = 0,
		}

	self.__ecol_updated = {
			id = 0,
			user_id = 0,
			csv_id = 0,
			name = 0,
			star = 0,
			us_prop_csv_id = 0,
			us_prop_num = 0,
			sharp = 0,
			skill_csv_id = 0,
			gather_buffer_id = 0,
			battle_buffer_id = 0,
			k_csv_id1 = 0,
			k_csv_id2 = 0,
			k_csv_id3 = 0,
			k_csv_id4 = 0,
			k_csv_id5 = 0,
			k_csv_id6 = 0,
			k_csv_id7 = 0,
			property_id1 = 0,
			value1 = 0,
			property_id2 = 0,
			value2 = 0,
			property_id3 = 0,
			value3 = 0,
			property_id4 = 0,
			value4 = 0,
			property_id5 = 0,
			value5 = 0,
		}

	for k,v in pairs(self.__head) do
		self.__fields[k] = assert(P[k], string.format("no exist %s", k))
	end
	return self
end

function cls:set_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["id"] = self.__ecol_updated["id"] + 1
	if self.__ecol_updated["id"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.id = v
end

function cls:get_id( ... )
	-- body
	return self.__fields.id
end

function cls:set_user_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["user_id"] = self.__ecol_updated["user_id"] + 1
	if self.__ecol_updated["user_id"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.user_id = v
end

function cls:get_user_id( ... )
	-- body
	return self.__fields.user_id
end

function cls:set_csv_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["csv_id"] = self.__ecol_updated["csv_id"] + 1
	if self.__ecol_updated["csv_id"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
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
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.name = v
end

function cls:get_name( ... )
	-- body
	return self.__fields.name
end

function cls:set_star(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["star"] = self.__ecol_updated["star"] + 1
	if self.__ecol_updated["star"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.star = v
end

function cls:get_star( ... )
	-- body
	return self.__fields.star
end

function cls:set_us_prop_csv_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["us_prop_csv_id"] = self.__ecol_updated["us_prop_csv_id"] + 1
	if self.__ecol_updated["us_prop_csv_id"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.us_prop_csv_id = v
end

function cls:get_us_prop_csv_id( ... )
	-- body
	return self.__fields.us_prop_csv_id
end

function cls:set_us_prop_num(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["us_prop_num"] = self.__ecol_updated["us_prop_num"] + 1
	if self.__ecol_updated["us_prop_num"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.us_prop_num = v
end

function cls:get_us_prop_num( ... )
	-- body
	return self.__fields.us_prop_num
end

function cls:set_sharp(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["sharp"] = self.__ecol_updated["sharp"] + 1
	if self.__ecol_updated["sharp"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.sharp = v
end

function cls:get_sharp( ... )
	-- body
	return self.__fields.sharp
end

function cls:set_skill_csv_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["skill_csv_id"] = self.__ecol_updated["skill_csv_id"] + 1
	if self.__ecol_updated["skill_csv_id"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.skill_csv_id = v
end

function cls:get_skill_csv_id( ... )
	-- body
	return self.__fields.skill_csv_id
end

function cls:set_gather_buffer_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["gather_buffer_id"] = self.__ecol_updated["gather_buffer_id"] + 1
	if self.__ecol_updated["gather_buffer_id"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.gather_buffer_id = v
end

function cls:get_gather_buffer_id( ... )
	-- body
	return self.__fields.gather_buffer_id
end

function cls:set_battle_buffer_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["battle_buffer_id"] = self.__ecol_updated["battle_buffer_id"] + 1
	if self.__ecol_updated["battle_buffer_id"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.battle_buffer_id = v
end

function cls:get_battle_buffer_id( ... )
	-- body
	return self.__fields.battle_buffer_id
end

function cls:set_k_csv_id1(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["k_csv_id1"] = self.__ecol_updated["k_csv_id1"] + 1
	if self.__ecol_updated["k_csv_id1"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.k_csv_id1 = v
end

function cls:get_k_csv_id1( ... )
	-- body
	return self.__fields.k_csv_id1
end

function cls:set_k_csv_id2(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["k_csv_id2"] = self.__ecol_updated["k_csv_id2"] + 1
	if self.__ecol_updated["k_csv_id2"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.k_csv_id2 = v
end

function cls:get_k_csv_id2( ... )
	-- body
	return self.__fields.k_csv_id2
end

function cls:set_k_csv_id3(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["k_csv_id3"] = self.__ecol_updated["k_csv_id3"] + 1
	if self.__ecol_updated["k_csv_id3"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.k_csv_id3 = v
end

function cls:get_k_csv_id3( ... )
	-- body
	return self.__fields.k_csv_id3
end

function cls:set_k_csv_id4(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["k_csv_id4"] = self.__ecol_updated["k_csv_id4"] + 1
	if self.__ecol_updated["k_csv_id4"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.k_csv_id4 = v
end

function cls:get_k_csv_id4( ... )
	-- body
	return self.__fields.k_csv_id4
end

function cls:set_k_csv_id5(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["k_csv_id5"] = self.__ecol_updated["k_csv_id5"] + 1
	if self.__ecol_updated["k_csv_id5"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.k_csv_id5 = v
end

function cls:get_k_csv_id5( ... )
	-- body
	return self.__fields.k_csv_id5
end

function cls:set_k_csv_id6(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["k_csv_id6"] = self.__ecol_updated["k_csv_id6"] + 1
	if self.__ecol_updated["k_csv_id6"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.k_csv_id6 = v
end

function cls:get_k_csv_id6( ... )
	-- body
	return self.__fields.k_csv_id6
end

function cls:set_k_csv_id7(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["k_csv_id7"] = self.__ecol_updated["k_csv_id7"] + 1
	if self.__ecol_updated["k_csv_id7"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.k_csv_id7 = v
end

function cls:get_k_csv_id7( ... )
	-- body
	return self.__fields.k_csv_id7
end

function cls:set_property_id1(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["property_id1"] = self.__ecol_updated["property_id1"] + 1
	if self.__ecol_updated["property_id1"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.property_id1 = v
end

function cls:get_property_id1( ... )
	-- body
	return self.__fields.property_id1
end

function cls:set_value1(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["value1"] = self.__ecol_updated["value1"] + 1
	if self.__ecol_updated["value1"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.value1 = v
end

function cls:get_value1( ... )
	-- body
	return self.__fields.value1
end

function cls:set_property_id2(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["property_id2"] = self.__ecol_updated["property_id2"] + 1
	if self.__ecol_updated["property_id2"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.property_id2 = v
end

function cls:get_property_id2( ... )
	-- body
	return self.__fields.property_id2
end

function cls:set_value2(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["value2"] = self.__ecol_updated["value2"] + 1
	if self.__ecol_updated["value2"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.value2 = v
end

function cls:get_value2( ... )
	-- body
	return self.__fields.value2
end

function cls:set_property_id3(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["property_id3"] = self.__ecol_updated["property_id3"] + 1
	if self.__ecol_updated["property_id3"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.property_id3 = v
end

function cls:get_property_id3( ... )
	-- body
	return self.__fields.property_id3
end

function cls:set_value3(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["value3"] = self.__ecol_updated["value3"] + 1
	if self.__ecol_updated["value3"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.value3 = v
end

function cls:get_value3( ... )
	-- body
	return self.__fields.value3
end

function cls:set_property_id4(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["property_id4"] = self.__ecol_updated["property_id4"] + 1
	if self.__ecol_updated["property_id4"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.property_id4 = v
end

function cls:get_property_id4( ... )
	-- body
	return self.__fields.property_id4
end

function cls:set_value4(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["value4"] = self.__ecol_updated["value4"] + 1
	if self.__ecol_updated["value4"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.value4 = v
end

function cls:get_value4( ... )
	-- body
	return self.__fields.value4
end

function cls:set_property_id5(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["property_id5"] = self.__ecol_updated["property_id5"] + 1
	if self.__ecol_updated["property_id5"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.property_id5 = v
end

function cls:get_property_id5( ... )
	-- body
	return self.__fields.property_id5
end

function cls:set_value5(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["value5"] = self.__ecol_updated["value5"] + 1
	if self.__ecol_updated["value5"] == 1 then
		self.__ecol_updated = self.__ecol_updated + 1
	end
	self.__fields.value5 = v
end

function cls:get_value5( ... )
	-- body
	return self.__fields.value5
end


return cls
