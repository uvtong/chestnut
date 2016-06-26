local entitycpp = require "entitycpp"

local cls = class("u_goodsentity", entitycpp)

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
			inventory = 0,
			countdown = 0,
			st = 0,
		}

	self.__ecol_updated = {
			id = 0,
			user_id = 0,
			csv_id = 0,
			inventory = 0,
			countdown = 0,
			st = 0,
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
		self.__col_updated = self.__col_updated + 1
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
		self.__col_updated = self.__col_updated + 1
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
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.csv_id = v
end

function cls:get_csv_id( ... )
	-- body
	return self.__fields.csv_id
end

function cls:set_inventory(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["inventory"] = self.__ecol_updated["inventory"] + 1
	if self.__ecol_updated["inventory"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.inventory = v
end

function cls:get_inventory( ... )
	-- body
	return self.__fields.inventory
end

function cls:set_countdown(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["countdown"] = self.__ecol_updated["countdown"] + 1
	if self.__ecol_updated["countdown"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.countdown = v
end

function cls:get_countdown( ... )
	-- body
	return self.__fields.countdown
end

function cls:set_st(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["st"] = self.__ecol_updated["st"] + 1
	if self.__ecol_updated["st"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.st = v
end

function cls:get_st( ... )
	-- body
	return self.__fields.st
end


return cls
