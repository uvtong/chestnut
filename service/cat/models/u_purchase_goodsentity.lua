local entitycpp = require "entitycpp"

local cls = class("u_purchase_goodsentity", entitycpp)

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
			num = 0,
			currency_type = 0,
			currency_num = 0,
			purchase_time = 0,
		}

	self.__ecol_updated = {
			id = 0,
			user_id = 0,
			csv_id = 0,
			num = 0,
			currency_type = 0,
			currency_num = 0,
			purchase_time = 0,
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

function cls:set_num(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["num"] = self.__ecol_updated["num"] + 1
	if self.__ecol_updated["num"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.num = v
end

function cls:get_num( ... )
	-- body
	return self.__fields.num
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

function cls:set_purchase_time(v, ... )
	-- body
	assert(v)
	self.__ecol_updated["purchase_time"] = self.__ecol_updated["purchase_time"] + 1
	if self.__ecol_updated["purchase_time"] == 1 then
		self.__col_updated = self.__col_updated + 1
	end
	self.__fields.purchase_time = v
end

function cls:get_purchase_time( ... )
	-- body
	return self.__fields.purchase_time
end


return cls
