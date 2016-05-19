local entitycpp = require "entitycpp"

local cls = class("g_achievemententity", entitycpp)

function cls:ctor(mgr, P, ... )
	-- body
	self.__head  = mgr.__head
	self.__tname = mgr.__tname
	self.__pk    = mgr.__pk
	self.__fk    = mgr.__fk
	self.__rdb   = mgr.__rdb
	self.__wdb   = mgr.__wdb
	self.__stm   = mgr.__stm
	self.__col_updated=0
	self.__fields = {
			csv_id = 0,
			type = 0,
			name = 0,
			c_num = 0,
			describe = 0,
			icon_id = 0,
			reward = 0,
			star = 0,
			unlock_next_csv_id = 0,
		}

	self.__ecol_updated = {
			csv_id = 0,
			type = 0,
			name = 0,
			c_num = 0,
			describe = 0,
			icon_id = 0,
			reward = 0,
			star = 0,
			unlock_next_csv_id = 0,
		}

	for k,v in pairs(self.__head) do
		self.__fields[k] = assert(P[k])
	end
	return self
end

function cls:csv_id(v, ... )
	-- body
	if v then
		self.csv_id = v
	else
		return self.csv_id
	end
end

function cls:type(v, ... )
	-- body
	if v then
		self.type = v
	else
		return self.type
	end
end

function cls:name(v, ... )
	-- body
	if v then
		self.name = v
	else
		return self.name
	end
end

function cls:c_num(v, ... )
	-- body
	if v then
		self.c_num = v
	else
		return self.c_num
	end
end

function cls:describe(v, ... )
	-- body
	if v then
		self.describe = v
	else
		return self.describe
	end
end

function cls:icon_id(v, ... )
	-- body
	if v then
		self.icon_id = v
	else
		return self.icon_id
	end
end

function cls:reward(v, ... )
	-- body
	if v then
		self.reward = v
	else
		return self.reward
	end
end

function cls:star(v, ... )
	-- body
	if v then
		self.star = v
	else
		return self.star
	end
end

function cls:unlock_next_csv_id(v, ... )
	-- body
	if v then
		self.unlock_next_csv_id = v
	else
		return self.unlock_next_csv_id
	end
end



return cls
