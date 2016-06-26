local entitycpp = require "entitycpp"

local cls = class("g_role_effectentity", entitycpp)

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
			buffer_id = 0,
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
			property_id6 = 0,
			value6 = 0,
			property_id7 = 0,
			value7 = 0,
			property_id8 = 0,
			value8 = 0,
		}

	self.__ecol_updated = {
			buffer_id = 0,
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
			property_id6 = 0,
			value6 = 0,
			property_id7 = 0,
			value7 = 0,
			property_id8 = 0,
			value8 = 0,
		}

	for k,v in pairs(self.__head) do
		self.__fields[k] = assert(P[k], string.format("no exist %s", k))
	end
	return self
end

function cls:set_buffer_id(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["buffer_id"] = self.__ecol_updated["buffer_id"] + 1
	if self.__ecol_updated["buffer_id"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.buffer_id = v
end

function cls:get_buffer_id( ... )
	-- body
	return self.__fields.buffer_id
end

function cls:set_property_id1(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["property_id1"] = self.__ecol_updated["property_id1"] + 1
	if self.__ecol_updated["property_id1"] == 1 then
		self.__col_updated = self.__col_updated + 1
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
		self.__col_updated = self.__col_updated + 1
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
		self.__col_updated = self.__col_updated + 1
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
		self.__col_updated = self.__col_updated + 1
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
		self.__col_updated = self.__col_updated + 1
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
		self.__col_updated = self.__col_updated + 1
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
		self.__col_updated = self.__col_updated + 1
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
		self.__col_updated = self.__col_updated + 1
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
		self.__col_updated = self.__col_updated + 1
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
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.value5 = v
end

function cls:get_value5( ... )
	-- body
	return self.__fields.value5
end

function cls:set_property_id6(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["property_id6"] = self.__ecol_updated["property_id6"] + 1
	if self.__ecol_updated["property_id6"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.property_id6 = v
end

function cls:get_property_id6( ... )
	-- body
	return self.__fields.property_id6
end

function cls:set_value6(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["value6"] = self.__ecol_updated["value6"] + 1
	if self.__ecol_updated["value6"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.value6 = v
end

function cls:get_value6( ... )
	-- body
	return self.__fields.value6
end

function cls:set_property_id7(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["property_id7"] = self.__ecol_updated["property_id7"] + 1
	if self.__ecol_updated["property_id7"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.property_id7 = v
end

function cls:get_property_id7( ... )
	-- body
	return self.__fields.property_id7
end

function cls:set_value7(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["value7"] = self.__ecol_updated["value7"] + 1
	if self.__ecol_updated["value7"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.value7 = v
end

function cls:get_value7( ... )
	-- body
	return self.__fields.value7
end

function cls:set_property_id8(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["property_id8"] = self.__ecol_updated["property_id8"] + 1
	if self.__ecol_updated["property_id8"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.property_id8 = v
end

function cls:get_property_id8( ... )
	-- body
	return self.__fields.property_id8
end

function cls:set_value8(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["value8"] = self.__ecol_updated["value8"] + 1
	if self.__ecol_updated["value8"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.value8 = v
end

function cls:get_value8( ... )
	-- body
	return self.__fields.value8
end


return cls
