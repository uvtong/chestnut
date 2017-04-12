local query = require "query"
local cls = class("field")

cls.data_type = {
	char = 1,
	integer  = 2,
	biginteger = 3,
	boolean = 4,
	uinteger  = 5,
	ubiginteger = 6,
}

options = {
	unique      = 1,
	primary_key = 2,
	foreign_key = 3,
	unsigned    = 4
}

function cls:ctor(entity, name, column, dt, primary_key, unique, foreign_key, unsigned, ... )
	-- body
	-- 1 ~ 8    column
	-- 2 ~ 16   type
	-- 17 ~ 24  options
	-- 24 ~ 32  changed
	-- self.name = name
	assert(entity and name and column and dt)
	entity._fields[column] = self

	self.entity = entity
	self.option = column & 0xff
	self.option = self.option | ((dt & 0xff) << 8)
	if primary_key then
		entity._pk = self
		self.option = self.option | (((1 << options.primary_key) & 0xff) << 16)
	end
	if unique then
		self.option = self.option | (((1 << options.unique) & 0xff) << 16)
	end
	if foreign_key then
		self.option = self.option | (((1 << options.foreign_key) & 0xff) << 16)
	end
	if unsigned then
		self.option = self.option | (((1 << options.unsigned) & 0xff) << 16)
	end
	
	self.name = name
	self.value = nil
end

function cls:unique( ... )
	-- body
	return (self.option >> 16 & (1 << options.unique) & 0xff > 0)
end

function cls:primary_key( ... )
	-- body
	return (self.option >> 16 & (1 << options.primary_key) & 0xff > 0)
end

function cls:foreign_key( ... )
	-- body
	return (self.option >> 16 & (1 << options.foreign_key) & 0xff > 0)
end

function cls:unsigned( ... )
	-- body
	return (self.option >> 16 & (1 << options.unsigned) & 0xff > 0)
end

function cls:column( ... )
	-- body
	return self.option & 0xff
end

function cls:dt( ... )
	-- body
	return (self.option >> 8) & 0xff
end
																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																																											
function cls:set_value(value, ... )
	-- body
	-- self.option = (self.option | (1 << 24))
	self.entity._changed[self.name] = value
	self.value = value
end

function cls:changed( ... )
	-- body
	return ((self.option >> 24) & 0xff > 0)
end
	
return cls