

local cls = class("field")

cls.data_type = {
	char = 1,
	integer  = 2,
	biginteger = 3
	boolean = 4,
}

options = {
	unique      = 1,
	primary_key = 2,
	foreign_key = 3,
	unsigned    = 4
}

function cls:ctor(entity, name, column, dt, primary_key, unique, foreign_key, unsigned ... )
	-- body
	-- 1 ~ 8    options
	-- 2 ~ 16   column
	-- 17 ~ 24  type
	-- self.name = name
	entity.fields[column] = self

	self.option = column & 0xff
	self.option = self.option | (((1 << dt) & 0xff) << 8)
	if primary_key then
		entity.pk = self
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
	
	-- self.name = name
	self.value = nil
end

function cls:set_value(value, ... )
	-- body

	self.value = value
end

return cls